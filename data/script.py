import json


def parse_questions(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()

    # Split questions by double newlines
    questions = content.strip().split("\n")
    result = []

    for question in questions:
        question_content = question.split("*")

        # Extract question ID and title from the first line
        question_id, title = question_content[0].split(maxsplit=1)

        answers = []
        clue = 0  # Counter for correct answers

        for line in question_content[1:]:
            # Check if the answer is correct
            is_correct = "[X]" in line

            # Clean the answer text
            answer_text = line.replace("[X]", "").replace("*", "").strip()

            if is_correct:
                clue += 1

            answers.append({"text": answer_text, "isCorrect": is_correct})

        # Add the processed question to the result
        result.append(
            {
                "questionId": int(question_id),
                "title": title,
                "answers": answers,
                "clue": clue,
                "isStarred": False
            }
        )

    return result


# Path to the uploaded file
file_path = "pyta.dat"
questions_json = parse_questions(file_path)

# Save the result to a JSON file
output_path = "questions.json"
with open(output_path, "w", encoding="utf-8") as json_file:
    json.dump(questions_json, json_file, indent=4, ensure_ascii=False)

print(f"Plik został przetworzony i zapisany jako {output_path}")
