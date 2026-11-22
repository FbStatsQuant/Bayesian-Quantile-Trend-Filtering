# SPod air-quality data (archived to the PC)

Seven raw SPod sensor files, one per day, 2018-06-15 to 2018-06-21 (fenceline sensor S08; the application in the paper uses n = 8,640 observations). Nothing in this repo reads them. They are archived to the PC through E-01 and were removed from git after the signed receipt.

- Source: TODO (Felipe: sensor owner / download URL).
- PC location: TODO (E-01 run id and path from the receipt).
- Receipt: TODO.

| File | Bytes | SHA-256 |
|---|---|---|
| S08_2018-06-15.csv | 20021011 | 6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3 |
| S08_2018-06-16.csv | 20058876 | 36e78ab80c2700bf123ac577d651f85e947f0f5bd22b2d2522fdac2d1d628d5e |
| S08_2018-06-17.csv | 20091148 | 535c50a75af89aaf20dad7becc61ebfb71abf6035118e59946f71dedddb09ef6 |
| S08_2018-06-18.csv | 20090383 | 965fe81583a3a66d83efb07da28000e0c1689a4a9597d5a5bf8ce8b641910d24 |
| S08_2018-06-19.csv | 20086240 | 1fa99078d852cae68f8411884730140311562d246919464fd1dff9f2d97d6e48 |
| S08_2018-06-20.csv | 19918147 | 7a2874e504cf845e0957ea08eb840a5311b97154374354d8a04703310c6b0b09 |
| S08_2018-06-21.csv | 19919522 | 8484b3b05b1baf8c0408063a8827fb133e130317d3fb2f338d93c5f42e828005 |

Check a restored copy (run in the folder holding the files): `sha256sum -c` on the lines below.

```
6086e8bdc1260cb90ca9250262aa7fc612a5e6e2d91490b7696f3e44f95cd7c3  S08_2018-06-15.csv
36e78ab80c2700bf123ac577d651f85e947f0f5bd22b2d2522fdac2d1d628d5e  S08_2018-06-16.csv
535c50a75af89aaf20dad7becc61ebfb71abf6035118e59946f71dedddb09ef6  S08_2018-06-17.csv
965fe81583a3a66d83efb07da28000e0c1689a4a9597d5a5bf8ce8b641910d24  S08_2018-06-18.csv
1fa99078d852cae68f8411884730140311562d246919464fd1dff9f2d97d6e48  S08_2018-06-19.csv
7a2874e504cf845e0957ea08eb840a5311b97154374354d8a04703310c6b0b09  S08_2018-06-20.csv
8484b3b05b1baf8c0408063a8827fb133e130317d3fb2f338d93c5f42e828005  S08_2018-06-21.csv
```
