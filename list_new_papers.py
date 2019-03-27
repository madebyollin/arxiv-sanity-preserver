import os
import time
import pickle
from   urllib.request import urlopen

from utils import Config

have = set(os.listdir(Config.pdf_dir)) # get list of all pdfs we already have

db = pickle.load(open(Config.db_path, 'rb'))
for pid, j in db.items():
    pdfs = [x['href'] for x in j['links'] if x['type'] == 'application/pdf']
    assert len(pdfs) == 1
    pdf_url = pdfs[0] + '.pdf'
    pdf_url = pdf_url.replace("http:","https:") # ??
    basename = pdf_url.split('/')[-1]
    fname = os.path.join(Config.pdf_dir, basename)
    if not basename in have:
        print(pdf_url)
