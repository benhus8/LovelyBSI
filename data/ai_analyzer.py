import json
import google.generativeai as genai
from dotenv import load_dotenv
import os
import re
import multiprocessing
import html

load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=GOOGLE_API_KEY)

def generate_explanation(question, model):
    prompt = f"""
    You are an expert in cybersecurity education tasked with explaining multiple-choice questions to students. Your goal is to provide clear, comprehensive explanations that help students understand fundamental cybersecurity concepts.

    Here is the question data you need to analyze:

    <question_data>
    {{
        "questionId": {question['questionId']},
        "title": "{question['title']}",
        "answers": [
    """
    for answer in question['answers']:
        prompt += f"""
            {{
                "text": "{answer['text']}",
                "isCorrect": {str(answer['isCorrect']).lower()}
            }},
         """
    prompt += """
        ]
    }}
    </question_data>

    Please follow these steps to create your explanation:

    1. Analyze the question and its answers carefully, considering the context of "Fundamentals of Cybersecurity".

    2. Wrap your analysis and planning process inside <analysis> tags. Consider:
       - The main topic or concept being tested
       - Key cybersecurity concepts present in the question
       - Potential misconceptions students might have about these concepts
       - Why each answer option is correct or incorrect
       - Any relevant additional information that would enhance understanding
       - An outline for the structure of your explanation

    3. Based on your analysis, create a comprehensive explanation in Polish that includes:
       - A brief introduction to the topic of the question
       - An explanation of why each correct answer is correct
       - An explanation of why each incorrect answer is incorrect
       - Clarification of potential misconceptions
       - Any relevant additional information that would help students better understand the concept

    4. Format your explanation within <explanation> tags.

    5. Identify 2-3 key points that students should remember about this topic and list them in Polish within <key_takeaways> tags.

    Maintain a professional yet approachable tone suitable for educational purposes. Your goal is to help students learn and understand the material thoroughly.
    Example output structure (do not copy the content, only the format):

    <analysis>
    [Your detailed analysis and planning in English]
    </analysis>

    <explanation>
    [Your detailed explanation in Polish markdown formatted]
    </explanation>

    <key_takeaways>
    - [Key point 1 in Polish markdown formatted]
    - [Key point 2 in Polish markdown formatted]
    - [Key point 3 in Polish markdown formatted]
    </key_takeaways>

    Remember to translate all student-facing content (explanation and key takeaways) into Polish.
    """

    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Error generating explanation: {e}")
        return None


def analyze_questions(file_path):
    model = genai.GenerativeModel('gemini-pro')

    with open(file_path, 'r', encoding='utf-8') as f:
        questions = json.load(f)

    lock = multiprocessing.Lock()

    with multiprocessing.Pool(initializer=init_lock, initargs=(lock,)) as pool:
        results = pool.map(process_question, [(question, model) for question in questions])

    for i, question in enumerate(questions):
        questions[i] = results[i]

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(questions, f, indent=4, ensure_ascii=False)

def process_question(args):
    question, model = args
    #title n/count
    with lock:
        print(f"Question: {question['title']} {question['questionId']}")
    explanation = generate_explanation(question, model)

    if explanation:
        analysis_match = re.search(r"<analysis>(.*?)</analysis>", explanation, re.DOTALL)
        explanation_match = re.search(r"<explanation>(.*?)</explanation>", explanation, re.DOTALL)
        key_takeaways_match = re.search(r"<key_takeaways>(.*?)</key_takeaways>", explanation, re.DOTALL)

        question['explanation'] = explanation_match.group(1).strip() if explanation_match else "Nie udało się wygenerować wyjaśnienia."
        key_takeaways_text = key_takeaways_match.group(1).strip() if key_takeaways_match else ""
        question['key_takeaways'] = [
            line.strip() for line in key_takeaways_text.splitlines() if line.strip()
        ]

    else:
        question['explanation'] = "Nie udało się wygenerować wyjaśnienia."
        question['key_takeaways'] = []

    with lock:
        print(f"Explanation: {question['explanation']}")
        print(f"Key Takeaways: {question['key_takeaways']}")
    return question

def init_lock(l):
    '''Store the lock for use in the process'''
    global lock
    lock = l

if __name__ == "__main__":
    file_path = 'questions.json'  # Replace with your actual file path
    analyze_questions(file_path)
    print(f"File {file_path} updated with explanations.")
