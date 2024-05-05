from file_funcs import *

# Before running this file, make sure that the other scripts have been run in order since an update to their code:
# 1. Range.py
# 2. RoundRange.py
# 3. EquivRound.py
# 4. ArcherEvent_Score_End_StagedEnd.py

MAX_LINES_TO_WRITE_PER_FILE = 15692

# This is a good order for inserting mock data, roughly follows foreign key dependencies
INSERT_FILE_NAMES = [
    'create_tables.sql',
    'Division.sql',
    'Equipment.sql',
    'Round_.sql',
    'Championship.sql',
    'Event_.sql',
    'Archer.sql',
    'EquivalentRound.sql',
    'ArcherEvent.sql',
    'Range_.sql',
    'RoundRange.sql',
    'Score.sql',
    'StagedEnd.sql',
    'End_.sql',
    'create_procedures.sql'
]

INSERT_FILE_NAMES = ['/'.join([SQL_FOLDER, name]) for name in INSERT_FILE_NAMES]

# Store complete file in buffer
buffer = []
for file_name in INSERT_FILE_NAMES:
	with open(file_name, 'r') as f_read:
		buffer = buffer + f_read.readlines()
		buffer.append('\n\n')
with open(SQL_FOLDER + '/output/batched_statements.sql', 'w') as f_out:
	f_out.writelines(buffer)

# Divide the buffer into batches of MAX_LINES_TO_WRITE_PER_FILE
output = list(splitArrayToSize(buffer, MAX_LINES_TO_WRITE_PER_FILE-1))
currentInsert = ''
for i in range(len(output)):
	if currentInsert != '':
		output[i].insert(0, currentInsert)
	for line in output[i]:
		if 'INSERT' in line:
			currentInsert = line
	output[i][-1] = ';'.join(output[i][-1].rsplit(',', 1)) # replaces final comma with semicolon
	with open(SQL_FOLDER + '/output/split_batched_statements{0}.sql'.format(i), 'w') as f_out:
		f_out.writelines(output[i])