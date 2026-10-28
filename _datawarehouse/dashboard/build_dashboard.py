"""Tinh so lieu cho dashboard tu data/data_raw.csv va ghep vao template.html -> dashboard.html.

Logic giong cac view SQL: gio dia phuong UTC-3, giao thuc, nhom dich vu, nhom tan cong.
Chay: py build_dashboard.py
"""
import csv
import json
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, '..', 'data', 'data_raw.csv')
TEMPLATE = os.path.join(HERE, 'template.html')
OUT = os.path.join(HERE, 'dashboard.html')

UTC_OFFSET_H = -3
PROTO_ORDER = [(1, 'ICMP'), (2, 'IGMP'), (6, 'TCP'), (17, 'UDP'), (132, 'SCTP')]


def attack_group(label):
    if label == 'benign':
        return 'Benign'
    if label.startswith('dos_'):
        return 'DoS'
    if label == 'ddos':
        return 'DDoS'
    if label.endswith('_patator'):
        return 'Brute Force'
    if label.startswith('webattack_'):
        return 'Web Attack'
    if label == 'portscan':
        return 'PortScan'
    if label == 'bot':
        return 'Bot'
    if label == 'heartbleed':
        return 'Heartbleed'
    return 'Other'


def median(vals):
    vals.sort()
    n = len(vals)
    if n % 2:
        return vals[n // 2]
    return (vals[n // 2 - 1] + vals[n // 2]) / 2


def main():
    proto_idx = {code: i for i, (code, _) in enumerate(PROTO_ORDER)}
    agg = {}
    durs = defaultdict(list)
    byts = defaultdict(list)
    observed = set()
    total = attacks = 0

    with open(SRC, newline='', encoding='utf-8') as f:
        rd = csv.reader(f)
        head = next(rd)
        ix = {c: i for i, c in enumerate(head)}
        i_ts, i_prot, i_port, i_lab = ix['timestamp'], ix['ip_prot'], ix['dst_port'], ix['label']
        i_fb, i_bb = ix['fwd_pkt_len_tot'], ix['bwd_pkt_len_tot']
        i_fp, i_bp = ix['fwd_pkt_cnt'], ix['bwd_pkt_cnt']
        i_du, i_bps = ix['flow_duration'], ix['bytes_per_s']

        for r in rd:
            sec = int(r[i_ts]) // 1_000_000 + UTC_OFFSET_H * 3600
            day = sec // 86400
            hour = (sec % 86400) // 3600
            wd = (day + 3) % 7  # 1970-01-01 la thu Nam; 0 = thu Hai
            label = r[i_lab]
            atk = 0 if label == 'benign' else 1
            nbytes = int(r[i_fb]) + int(r[i_bb])
            npkt = int(r[i_fp]) + int(r[i_bp])
            dur = int(r[i_du])
            key = (wd, hour, proto_idx[int(r[i_prot])], int(r[i_port]), label)
            a = agg.get(key)
            if a is None:
                a = agg[key] = [0, 0, 0, 0, 0, 0.0]
            a[0] += 1
            a[1] += atk
            a[2] += nbytes
            a[3] += npkt
            a[4] += dur
            a[5] += float(r[i_bps])
            durs[label].append(dur)
            byts[label].append(nbytes)
            observed.add((day, hour))
            total += 1
            attacks += atk

    labels = ['benign'] + sorted(l for l in durs if l != 'benign')
    lidx = {l: i for i, l in enumerate(labels)}
    rows = [
        [k[0], k[1], k[2], k[3], lidx[k[4]], v[0], v[1], v[2], v[3], v[4], round(v[5], 3)]
        for k, v in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1], kv[0][2], kv[0][3], lidx[kv[0][4]]))
    ]
    data = {
        'protocols': [n for _, n in PROTO_ORDER],
        'labels': [[l, attack_group(l), 0 if l == 'benign' else 1] for l in labels],
        'med': {l: [median(durs[l]), median(byts[l])] for l in labels},
        'rows': rows,
    }

    with open(TEMPLATE, encoding='utf-8') as f:
        html = f.read()
    html = html.replace('/*__DATA__*/null', json.dumps(data, separators=(',', ':'), ensure_ascii=False))
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write(html)

    print('tong luong:', total, '| luong tan cong:', attacks)
    print('so o cuboid (gio x giao thuc x cong x nhan):', len(rows))
    print('so gio co du lieu:', len(observed))
    print('trung vi byte webattack_xss / dos_slowhttptest:',
          data['med']['webattack_xss'][1], data['med']['dos_slowhttptest'][1])
    print('da ghi:', OUT, '|', round(os.path.getsize(OUT) / 1024), 'KB')


if __name__ == '__main__':
    main()
