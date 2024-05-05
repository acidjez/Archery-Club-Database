file_name = "Insert Statements\EquivalentRound.sql"
equivalent_round_id = "null"
effective_date = "2022-06-07"

division_names = [
	# 'Male Open',
	'Female Open',
	'50+ Male',
	'50+ Female',
	'60+ Male',
	'60+ Female',
	'70+ Male',
	'70+ Female',
	# 'Under 21 Male',
	'Under 21 Female',
	'Under 18 Male',
	'Under 18 Female',
	'Under 16 Male',
	'Under 16 Female',
	'Under 14 Male',
	'Under 14 Female'
]

bow_types = [
	'Recurve',
	'Compound',
	'Recurve Barebow',
	'Compound Barebow',
	'Longbow'
]

with open(file_name, "w") as f:
	f.write("INSERT TABLE EquivalentRound (equivalent_round_id, division_name, bow_type, round_id, effective_date) VALUES\n")
	for round_id in range (1, 40):
		for division_name in division_names:
			for bow_type in bow_types:
				f.write("({}, '{}', '{}', '{}', '{}')\n".format(equivalent_round_id, division_name, bow_type, round_id, effective_date))


# (round_id, division_name, bow_type, equivalent_round_name, effective_date)
# (1, 'Female Open', 'Recurve', 'WA70/1440', ''),