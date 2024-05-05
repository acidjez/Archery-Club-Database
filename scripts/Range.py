from file_funcs import *

FILE_NAME = SQL_FOLDER + '/' + 'Range_.sql'

DISTANCE = [
	90,
	70,
	60,
	50,
	40,
	30,
	20,
	10
]
NUM_ENDS = [
	5,
	6
]
FACE_SIZE = [
	'80cm',
	'122cm'
]

with open(FILE_NAME, "w") as f:
	f.write("INSERT INTO Range_ (num_ends, distance, face_size) VALUES\n")
	for dist in DISTANCE:
		for nend in NUM_ENDS:
			for fsize in FACE_SIZE:
				f.write("({}, {}, '{}'),\n".format(nend, dist, fsize))

delimit_end_of_file(FILE_NAME)