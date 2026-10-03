## A note on the data

The two CSV files in `data/` use the column names from the palmerpenguins
package, with units in the names:

| Column              | Meaning                       |
|---------------------|-------------------------------|
| `species`           | Adelie, Chinstrap, or Gentoo  |
| `island`            | Island where measured         |
| `bill_length_mm`    | Bill length in millimeters    |
| `bill_depth_mm`     | Bill depth in millimeters     |
| `flipper_length_mm` | Flipper length in millimeters |
| `body_mass_g`       | Body mass in grams            |
| `sex`               | Recorded sex                  |

R 4.5 and later also ship a `penguins` dataset in base R's `datasets`
package, but it names these columns differently (`bill_len`, `bill_dep`,
`flipper_len`, `body_mass`). If you load that version instead of the CSVs,
the lesson code will not find the columns it expects. The workshop always
reads the CSV files, so you do not need to load either package's data.

The split into "2024" and "2025" files is a teaching device. The original
measurements were collected between 2007 and 2009 (Gorman et al. 2014; see
`CITATION.cff`).