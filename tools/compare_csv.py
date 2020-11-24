#! /usr/bin/env python

from __future__ import print_function


import csv
import argparse
import sys


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('filename', nargs=2)
    parser.add_argument('--key', '-k', type=int, default=2,
                        help='Key column of CSV file (default=2)')
    parser.add_argument('--error', '-e', type=float, default=1e-6,
                        help='Maximum error (default=1e-6)')

    args = parser.parse_args()

    return args


def load_csv(name):
    csv_lines = []
    with open(name) as csvfile:
        csvreader = csv.reader(csvfile, delimiter=',', quotechar='|')
        for row in csvreader:
            csv_lines.append(row)

    n = len(csv_lines)
    print("\n", name, "has", n, "lines")

    for i in range(5):
        print(csv_lines[i])
    print("    ...")
    for i in range(n-6, n-1):
        print(csv_lines[i])

    return csv_lines


def make_dict(csv, key):
    mydict = {}

    for row in csv:
        if len(row) >= key:
            mydict[row[key]] = row

    return mydict


def will_it_float(value):
    try:
        float(value)
        return True
    except ValueError:
        return False


def compare_rows(row1, row2, err=1e-6):
    if len(row1) != len(row2):
        print("Rows have different lengths")
        return False

    ok = True
    for a, b in zip(row1, row2):
        if a != b:
            if will_it_float(a) and will_it_float(b):
                v1 = float(a)
                v2 = float(b)
                verror = abs(v1 - v2)
                if verror > err:
                    ok = False
    return ok


def compare_csvs(csv1, csv2, key, err):
    dict1 = make_dict(csv1, key)
    dict2 = make_dict(csv2, key)

    ok_count = 0
    bad_count = 0

    for k in dict1:
        row1 = dict1[k]
        try:
            row2 = dict2[k]
        except KeyError:
            print("Uh-oh, no key", k, "in 2nd CSV")
            bad_count = bad_count+1
            continue

        if compare_rows(row1, row2, err):
            ok_count = ok_count+1
        else:
            bad_count = bad_count+1
            print("Mismatch for key", k)
            print(row1)
            print(row2)

    print("")
    print(ok_count, "rows match")
    print(bad_count, "rows do not match\n")

    return bad_count


if __name__ == '__main__':

    args = parse_args()

    csv1 = load_csv(args.filename[0])
    csv2 = load_csv(args.filename[1])

    ret = compare_csvs(csv1, csv2, args.key, args.error)

    sys.exit(ret)
