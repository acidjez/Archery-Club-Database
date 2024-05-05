import random
from file_funcs import *

random.seed()


DIVS = [
	'Male Open',
	'Female Open',
	'50+ Male',
	'50+ Female',
	'60+ Male',
	'60+ Female',
	'70+ Male',
	'70+ Female',
	'Under 21 Male',
	'Under 21 Female',
	'Under 18 Male',
	'Under 18 Female',
	'Under 16 Male',
	'Under 16 Female',
	'Under 14 Male',
	'Under 14 Female'
]

EQUIPS = [
    'Recurve',
    'Compound',
    'Recurve Barebow',
    'Compound Barebow',
    'Longbow'
]

BASE_ROUND_IDS = [
    1,
    6,
    8,
    11,
    14,
    18,
    22,
    25,
    29,
    32,
    37
]

round_file_path = SQL_FOLDER + '/' + 'Round_.sql'
rounds_data = read_rows_from_file(round_file_path, True)

div_offsets = [0, 1, 1, 2, 2, 2, 3, 3, 0, 1, 1, 2, 3, 3, 4, 4] 
effective_date = "2022-06-07"

equiv_round_path = SQL_FOLDER + '/' + 'EquivalentRound.sql'

with open(equiv_round_path, "w") as f:
    f.write("INSERT INTO EquivalentRound (equiv_round_id, division_name, bow_type, base_round_id, effective_date) VALUES\n")

    for round in rounds_data:
        round_id, _ = round

        # Every round should have one entry in EquivalentRound for self-reference
        f.write("({}, {}, {}, {}, '{}'), \n".format(round_id, 'null', 'null', round_id, 'null'))
        
        # If we want this to be a base round, generate the equivalent rounds for it
        if round_id in BASE_ROUND_IDS:
            for div in DIVS:
                equip_offset = 0
                for equipment in EQUIPS:
                        # this only works cos our rounds are entered pretty sequentially
                        # works for test data though :D
                        equiv_id = min((min((round_id + equip_offset + div_offsets[DIVS.index(div)]), round_id + 5)), len(rounds_data))
                        f.write("({}, '{}', '{}', {}, '{}'), \n".format(equiv_id, div, equipment, round_id, effective_date))

                        e_chance = random.randint(1, 100)

                        if (EQUIPS.index(equipment) > 1 and e_chance <= 90):
                            equip_offset += 1
    f.close()

# change the last entry to delimit with ;
with open(equiv_round_path, "r") as f:
    data = f.read();
    data = data[:-3] + ";"
    f.close()
with open(equiv_round_path, "w") as f:
    f.write(data)
    f.close()