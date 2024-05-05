import random
from datetime import datetime
from file_funcs import *


def generate_random_integers(n, minimum, maximum):
    if n > maximum - minimum + 1:
        raise ValueError("Cannot generate {} non-repeating integers between {} and {}.".format(n, minimum, maximum))

    integers = random.sample(range(minimum, maximum + 1), n)
    return integers

# Folder where sql files are kept

#### READ MOCK DATA ####
equivrounds_path = SQL_FOLDER + '/' + 'EquivalentRound.sql'
equivalent_rounds = read_rows_from_file(equivrounds_path, True)

archers_path = SQL_FOLDER + '/' + 'Archer.sql'
archers = read_rows_from_file(archers_path, True)

events_path = SQL_FOLDER + '/' + 'Event_.sql'
events = read_rows_from_file(events_path, True)

ranges_path = SQL_FOLDER + '/' + 'Range_.sql'
ranges = read_rows_from_file(ranges_path, True)

roundranges_path = SQL_FOLDER + '/' + 'RoundRange.sql'
roundranges = read_rows_from_file(roundranges_path, False)


# File paths to write to
archer_event_path = SQL_FOLDER + '/' + 'ArcherEvent.sql'
score_path = SQL_FOLDER + '/' + 'Score.sql'
end_path = SQL_FOLDER + '/' + 'End_.sql'
stagedend_path = SQL_FOLDER + '/' + 'StagedEnd.sql'

today = datetime.today().strftime('%Y-%m-%d')

score_id = 0

######## GENERATE DATA ########
#
# Make sure to run this after making any new test data in any of the 'READ MOCK DATA' files above
#

archer_events = []
scores = []
ends = []
staged_ends = []
t_types = []
for event in events:
    event_id, round_id, is_competition, champ_id, is_completed, event_name, event_date, event_location = event
    # Generate 10-40 entries for each archer in various events
    num_entries = random.randint(10, 40)

    # Generate a list of IDs of length num_entries
    archer_ids = generate_random_integers(num_entries, 1, len(archers)) 

    for a_id in archer_ids:
        archer_id, first_name, last_name, dob, gender, default_bow, phone = archers[a_id - 1]
        age = (datetime.strptime(today, '%Y-%m-%d') - datetime.strptime(dob, '%Y-%m-%d')).days // 365
        division = ''
        bow_type = default_bow

        # This represents whether the archer has stopped entering their ends in an incomplete round
        bStopEnds = False

        # Determine division and bow type based on age, gender, and default bow
        if age >= 70:
            division = '70+ Male' if gender == 'M' else '70+ Female'
        elif age >= 60:
            division = '60+ Male' if gender == 'M' else '60+ Female'
        elif age >= 50:
            division = '50+ Male' if gender == 'M' else '50+ Female'
        elif age >= 21:
            division = 'Male Open' if gender == 'M' else 'Female Open'
        elif age >= 18:
            division = 'Under 21 Male' if gender == 'M' else 'Under 21 Female'
        elif age >= 16:
            division = 'Under 18 Male' if gender == 'M' else 'Under 18 Female'
        elif age >= 14:
            division = 'Under 16 Male' if gender == 'M' else 'Under 16 Female'
        else:
            division = 'Under 14 Male' if gender == 'M' else 'Under 14 Female'

        derived_round_pk = None
        round_self_pk = None
        derived_round_id = None

        # Find the archer's equivalent round PK from EquivalentRound table if it exists
        for round_data in equivalent_rounds:
            equiv_round_pk, equiv_round_id, div_name, b_type, base_round_id, effective_date = round_data

            if base_round_id == round_id and div_name == division and b_type == bow_type:
                derived_round_pk = equiv_round_pk
                derived_round_id = equiv_round_id
                break
            
            # in case there isn't an equivalent round, also look for the self-ref row
            if round_self_pk == None and (div_name == None and b_type == None and base_round_id == round_id and equiv_round_id == round_id):
                round_self_pk = equiv_round_pk
        
        if derived_round_pk == None: 
            derived_round_pk = round_self_pk
            derived_round_id = round_id
        
        archer_events.append([event_id, archer_id, derived_round_pk, division, bow_type])

        # Generate mock data for Scores, 1 score for each range in the ArcherEvent's round

        # Get list of RoundRange rows in the round
        range_list = [row for row in roundranges if row[0] == derived_round_id]
        # Add a score for each range in the round
        
        for range_num in range(1, len(range_list) + 1):
            score_id += 1
            scores.append([score_id, archer_id, event_id, range_num])
            

            _, _, range_id = range_list[range_num - 1]
            _, num_ends, _, _ = ranges[range_id - 1]

            for end_num in range(1, num_ends + 1):
                arrow_points = [random.randint(0,11) for _ in range(6)]
                end_row = [score_id, end_num] + arrow_points

                if is_completed == 'true':
                    ends.append(end_row)
                else:
                    done_chance = random.randint(1,12)
                    if done_chance == 1: bStopEnds = True
                    if not bStopEnds: staged_ends.append(end_row)


##### WRITE DATA #####

# Write to ArcherEvent.sql
with open(archer_event_path, "w") as f:
    f.write("INSERT INTO ArcherEvent (event_id, archer_id, equiv_round_pk, division_name, bow_type) VALUES\n")
    for archer_event in archer_events:
        event_id, archer_id, round_pk, division_name, bow_type = archer_event
        f.write("({}, {}, {}, '{}', '{}'),\n".format(event_id, archer_id, round_pk, division_name, bow_type))
    f.close()

delimit_end_of_file(archer_event_path)

# Write to Score.sql
with open(score_path, "w") as f:
    f.write("INSERT INTO Score (archer_id, event_id, range_num) VALUES\n")
    for score in scores:
        _, archer_id, event_id, range_num = score
        f.write("({}, {}, {}),\n".format(archer_id, event_id, range_num))
    f.close()

delimit_end_of_file(score_path)

# Write to End_.sql
with open(end_path, "w") as f:
    f.write("INSERT INTO End_ (score_id, end_num, arrow1, arrow2, arrow3, arrow4, arrow5, arrow6) VALUES\n")
    for end in ends:
        f.write("({}, {}, {}, {}, {}, {}, {}, {}),\n".format(*end))
    f.close()

delimit_end_of_file(end_path)

# Write to End_.sql
with open(stagedend_path, "w") as f:
    f.write("INSERT INTO StagedEnd (score_id, end_num, arrow1, arrow2, arrow3, arrow4, arrow5, arrow6) VALUES\n")
    for end in staged_ends:
        f.write("({}, {}, {}, {}, {}, {}, {}, {}),\n".format(*end))
    f.close()

delimit_end_of_file(stagedend_path)



