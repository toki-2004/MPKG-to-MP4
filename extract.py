#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MPKG to MP4 - Wallpaper Engine (.mpkg) package extraction tool

Pure Python standard library, no third-party dependencies required.

Usage:
    python extract.py <package.mpkg> [output_dir]
"""

import argparse
import os
import sys

SIGNATURE = b"PKGM0014"
HEADER_SIZE = 16  # 8-byte magic + version/count fields


class PkgError(Exception):
    """Raised when the package file is invalid or corrupted."""


def parse_pkg(path):
    """Parse a PKGM0014 container and return a list of file entries."""
    with open(path, "rb") as f:
        data = f.read()

    if len(data) < HEADER_SIZE or data[4:12] != SIGNATURE:
        raise PkgError("Not a valid Wallpaper Engine package (missing PKGM0014 signature)")

    count = int.from_bytes(data[12:16], "little")
    pos = HEADER_SIZE
    entries = []

    for _ in range(count):
        if pos + 4 > len(data):
            raise PkgError("Package header is truncated")
        name_len = int.from_bytes(data[pos:pos + 4], "little")
        pos += 4
        if pos + name_len > len(data):
            raise PkgError("Package header is truncated")
        name = data[pos:pos + name_len].decode("utf-8", errors="replace")
        pos += name_len
        if pos + 8 > len(data):
            raise PkgError("Package header is truncated")
        offset = int.from_bytes(data[pos:pos + 4], "little")
        size = int.from_bytes(data[pos + 4:pos + 8], "little")
        pos += 8
        entries.append({"name": name, "offset": offset, "size": size})

    data_region = pos
    for entry in entries:
        start = data_region + entry["offset"]
        end = start + entry["size"]
        if start < data_region or end > len(data):
            raise PkgError("File '{}' data is out of bounds; package may be corrupted".format(entry["name"]))
        entry["data"] = data[start:end]

    return entries


def extract(pkg_path, out_dir):
    """Extract all files from a package; MP4 files are also copied to the top level."""
    entries = parse_pkg(pkg_path)
    os.makedirs(out_dir, exist_ok=True)
    results = []
    stem = os.path.splitext(os.path.basename(pkg_path))[0]

    for entry in entries:
        dst = os.path.join(out_dir, entry["name"])
        with open(dst, "wb") as f:
            f.write(entry["data"])
        results.append((entry["name"], len(entry["data"]), dst))

        if entry["name"].lower().endswith(".mp4"):
            mp4_dst = os.path.join(out_dir, stem + ".mp4")
            with open(mp4_dst, "wb") as f:
                f.write(entry["data"])
            results.append((entry["name"] + " (copy)", len(entry["data"]), mp4_dst))

    return results


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Extract videos and files from Wallpaper Engine .mpkg packages"
    )
    parser.add_argument("pkg", help="path to the .mpkg package")
    parser.add_argument(
        "out",
        nargs="?",
        default=None,
        help="output directory (default: <pkg_stem>_extracted next to the package)",
    )
    args = parser.parse_args(argv)

    pkg_path = args.pkg
    if not os.path.isfile(pkg_path):
        print("Error: file not found: {}".format(pkg_path))
        return 1

    if args.out:
        out_dir = args.out
    else:
        stem = os.path.splitext(os.path.basename(pkg_path))[0]
        out_dir = os.path.join(os.path.dirname(os.path.abspath(pkg_path)), stem + "_extracted")

    try:
        results = extract(pkg_path, out_dir)
    except PkgError as exc:
        print("Error: {}".format(exc))
        return 1
    except OSError as exc:
        print("Error: {}".format(exc))
        return 1

    print("Extracted {} file(s) -> {}".format(len(results), out_dir))
    for name, size, dst in results:
        print("  {:<24} {:>12,} bytes  -> {}".format(name, size, dst))
    return 0


if __name__ == "__main__":
    sys.exit(main())
