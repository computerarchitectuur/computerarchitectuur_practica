#!/usr/bin/python3
import json

# Decode address range, using copious validation
def decode_address_range(answer):
    assert '-' in answer, 'Geen koppelteken gebruikt bij het ingeven van het adresbereik!'
    tokens = answer.split('-')
    assert len(tokens) == 2, 'Te veel koppeltekens bij het ingeven van het adresbereik!'
    start = int(tokens[0])
    end = int(tokens[1])
    return (start, end)

def ask_cache_contents_part1(iteration):
    contents = []
    print('Geef de inhoud van de cache op iteratie: ' + str(iteration))
    for iii in range(0, 4):
        answer = input('Geef het bereik van adressen aanwezig in blok ' + str(iii) + ' in de vorm BEGINADRES-EINDADRES (eindadres inclusief): ')
        contents.append(decode_address_range(answer))

    return contents

def ask_cache_contents_part2(iteration):
    contents = []
    print('Geef de inhoud van de cache op iteratie: ' + str(iteration))
    for iii in range(0, 2):
        blocks = []
        for jjj in range(0, 4):
            answer = input('Geef het bereik van adressen aanwezig in set ' + str(iii) + ' blok ' + str(jjj) + ' in de vorm BEGINADRES-EINDADRES (eindadres inclusief): ')
            blocks.append(decode_address_range(answer))
        contents.append(blocks)

    return contents

def ask_question(answers, question_id, answer_function, *args):
    print()
    print('VRAAG ' + question_id)
    answers[question_id] = answer_function(*args)

if __name__ == '__main__':
    # We will fill in a results dictionary by asking questions, then dump it at the end of this program
    results = {}
    answers = {}
    results['answers'] = answers

    # Gather general group information
    results['group_id'] = int(input("Geef uw groepsnummer in: "))

    # Get the answers for the actual questions
    ask_question(answers, 'Dubbele lus 1a', ask_cache_contents_part1, 10)
    ask_question(answers, 'Dubbele lus 1b', ask_cache_contents_part1, 20)
    ask_question(answers, 'Dubbele lus 1c', ask_cache_contents_part1, 50)

    ask_question(answers, 'Matrixvermenigvuldiging 1c', ask_cache_contents_part2, 50)

    ask_question(answers, 'Matrixvermenigvuldiging 3a', ask_cache_contents_part2, 10)
    ask_question(answers, 'Matrixvermenigvuldiging 3b', ask_cache_contents_part2, 20)
    ask_question(answers, 'Matrixvermenigvuldiging 3c', ask_cache_contents_part2, 50)

    # Dump the results as a JSON file
    with open('practicum8_resultaten.json', 'w') as f_res:
        json.dump(results, f_res)
