#!/usr/bin/env python3
import json
from argparse import ArgumentParser


def run(args):
    with open(args.filename, 'r') as f:
        s = f.read()
    j = json.loads(s)
    if type(j) != list:
        raise ValueError('JSON file is not of type list')
    sj = list(sorted(j))
    with open(args.filename, 'w') as f:
        f.write(json.dumps(sj, separators=(',', ':')))


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('filename')
    args = parser.parse_args()

    run(args)
