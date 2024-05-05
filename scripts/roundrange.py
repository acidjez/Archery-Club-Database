
import random
from file_funcs import *

random.seed()

FILE_NAME = SQL_FOLDER + '/' + 'RoundRange.sql'

with open(FILE_NAME, "w") as f:
    f.write("INSERT INTO RoundRange (round_id, range_num, range_id) VALUES\n")
    for round_id in range(1, 39):
        num_ranges = random.randint(2,4)
        range_id = 0
        for range_num in range(1, num_ranges + 1):
            range_id += random.randint(1,10)
            f.write("({}, {}, {}),\n".format(round_id, range_num, range_id))
    
    f.close()

delimit_end_of_file(FILE_NAME)