SQL_FOLDER = "create_insert_statements"

def read_rows_from_file(file_path, add_row_number=False):
    rows = []
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for i, line in enumerate(lines[1:], start=1):
            line = line.strip().strip("(),;")
            values = line.split(', ')
            row = []
            if add_row_number:
                row.append(i)
            for value in values:
                if value.isdigit():
                    row.append(int(value))
                elif value == 'null':
                    row.append(None)
                else:
                    row.append(value.strip("'"))
            rows.append(row)
    return rows

def delimit_end_of_file(file_path, end_chars=2):
    with open(file_path, "r") as f:
        data = f.read();
        data = data[:-end_chars] + ";"
    with open(file_path, "w") as f:
        f.write(data)

def splitArrayToSize(array, size):
	for i in range(0, len(array), size):
		yield array[i:i + size]