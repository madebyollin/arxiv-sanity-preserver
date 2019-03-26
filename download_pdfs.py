import os
import time
import pickle
import shutil
import random
import console
from   urllib.request import urlopen

from utils import Config

timeout_secs = 10 # after this many seconds we give up on a paper
if not os.path.exists(Config.pdf_dir): os.makedirs(Config.pdf_dir)
have = set(os.listdir(Config.pdf_dir)) # get list of all pdfs we already have

num_ok = 0
num_total = 0
db = pickle.load(open(Config.db_path, 'rb'))
for pid, j in db.items():
    pdfs = [x['href'] for x in j['links'] if x['type'] == 'application/pdf']
    assert len(pdfs) == 1
    pdf_url = pdfs[0] + '.pdf'
    basename = pdf_url.split('/')[-1]
    fname = os.path.join(Config.pdf_dir, basename)

    # try retrieve the pdf
    num_total += 1
    try:
        if not basename in have:
            console.log('fetching %s into %s' % (pdf_url, fname))
            req = urlopen(pdf_url, None, timeout_secs)
            with open(fname, 'wb') as fp:
                shutil.copyfileobj(req, fp)
            time.sleep(0.05 + random.uniform(0, 0.1))
        else:
            console.info('%s exists, skipping' % (fname, ))
            num_ok += 1
    except Exception as e:
        console.warn('error downloading: ', pdf_url)
        console.log(e)

    console.info('%d/%d of %d downloaded ok.' % (num_ok, num_total, len(db)))

console.h1('Final number of papers downloaded okay: %d/%d' % (num_ok, len(db)))
