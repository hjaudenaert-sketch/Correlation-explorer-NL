## 1. What is this website?

Buurt Explorer helps you look for patterns between two things in Dutch neighbourhoods. For example: do neighbourhoods with higher incomes also have healthier people? You pick two things, and the website draws a **scatter plot** and a **colour map**.

It is meant for inspiration and a starting point. Use it to find ideas, then check them properly yourself (see chapter 7).

## 2. Quick start

1. Choose a **year**, a **city** and a **level** (buurt or wijk) on the left.
2. Choose **Variable X** and **Variable Y**. Type a word to search, or press *Browse variables*.
3. Look at the **Scatter plot** tab. Every dot is one area.
4. Open the **Map** tab to see the same areas on a map.
5. Change the look with the **Style** panel on the right.
6. Save your picture with *Download*, or go to **Data and script** to get the numbers.

The language button (NL | EN) and this manual are always in the top right corner. Every small **i** opens a short explanation.

## 3. Filters

**Year.** Which year's numbers and borders you use. Borders of buurten change a little each year, so numbers and map always come from the same year.

**City.** Type a name, or press *Choose on map* and click your city on the map of the Netherlands. You can search at the top of that map too. Move your mouse over a city to see its name.

**Level.** A *buurt* is a small neighbourhood. A *wijk* is a bigger district made of several buurten.

**Variable X and Y.** The two things you compare. X goes along the bottom, Y goes up the side. Press *Browse variables* to see them all, grouped **by theme** (the subject, like income or health) or **by data type** (what kind of numbers they are). The **i** next to a variable tells you what it means and what type of data it is. The text under the box shows the type of your current choice.

**Scatter plot.** One dot per area. The line is the *regression line*: the straight line that fits best through the dots. The **n** at the bottom is the number of areas in the plot. Areas without a value for X or Y are left out. Move your mouse over a dot to see which area it is.

**Lasso select / deselect.** Two buttons at the top right of the plot. With *lasso select* you draw a loop around dots to highlight them. With *lasso deselect* you remove the highlight. It does not change the line or the map.

**Map.** The same areas with colours.
- *Bivariate*: both variables at once. A 3 x 3 colour grid: light = low on both, dark = high on both, and the mixed colours show where one is high and the other low.
- *Single variable*: one colour range for X or Y.
- Grey areas have no data. Move your mouse over an area to see its name and values.

**Style.** Changes how the picture looks (titles, colours, sizes, borders). It never changes the numbers. Leave a box empty to use the default.

**Export.** Width and height in centimetres, DPI (sharpness; 300 for print, 150 for screens), and the file type (PNG, SVG or PDF).

**Data and script.** Downloads a zip with: the data (`data.csv`), the area shapes (`areas.gpkg`), a text file with sources and variable explanations (`README_metadata.txt`) and a script for **R** or **SPSS** that runs the real statistics for you.

## 4. How to read a scatter plot

- Dots going up from left to right: when X is higher, Y tends to be higher too (*positive* relationship).
- Dots going down: when X is higher, Y tends to be lower (*negative* relationship).
- Dots in a cloud without direction: no clear relationship.
- The tighter the dots around the line, the stronger the relationship.

A relationship is not proof that one thing *causes* the other. Ice cream sales and sunburn go up together, but ice cream does not cause sunburn: the sun does.

## 5. What kind of data can you use?

Not all numbers are the same. Statisticians call this the 'level of measurement'.

| Type | What it is | Example | Correlation allowed? |
|---|---|---|---|
| **Nominal** (categories) | Names without order | Type of area: city, village | No. Use group comparisons instead. Not offered here. |
| **Ordinal** (ordered classes) | Order, but unequal gaps | Urbanity 1 to 5 | Rank correlation (Spearman). Not Pearson. |
| **Interval** | Equal gaps, zero is arbitrary | Temperature in Celsius | Yes. |
| **Ratio** | Equal gaps, zero means 'none' | Income, age, distance, counts, percentages | Yes. |

Almost all variables here are **ratio** variables, split in four groups:

- **Counts** (inhabitants, houses). Careful: big areas have big counts for everything. Two counts will almost always correlate, simply because both follow the size of the area. This is called the *size effect*. Prefer percentages or rates.
- **Percentages** (share of people over 65). Fair between areas of different size. They stay between 0 and 100, and percentages that add up to a whole (like age groups) pull each other down.
- **Rates and densities** (inhabitants per km2). Fair, but a few very crowded areas can be extreme outliers.
- **Amounts and averages** (average income). Averages hide differences inside an area. Very skewed data (like income) often looks better after a log transformation, or you can use Spearman.

### Combinations and what they mean

| X and Y | What to do |
|---|---|
| Ratio and ratio | Pearson correlation is fine. Check the plot for outliers and curved patterns. Spearman is a safe alternative. |
| Ratio and ordinal | Use Spearman. |
| Ordinal and ordinal | Use Spearman or Kendall. |
| Count and count | Be suspicious: probably the size effect. Switch to percentages or rates. |
| Anything with a nominal variable | Correlation does not work. Compare groups instead (for example a t-test or ANOVA). |

The consequence of a wrong choice: a number comes out, but it means nothing, or it points in the wrong direction. The plot always draws a straight line, even when it does not fit. So always look at the dots, not only at the line.

## 6. Traps to avoid

- **Ecological fallacy.** A pattern between areas does not apply to individual people. A rich buurt with healthy people does not mean that rich individuals are healthier.
- **Neighbours are alike.** Buurten next to each other tend to resemble each other (*spatial autocorrelation*). Your dots are not truly independent, so tests make results look more certain than they are.
- **Borders matter.** Cutting the map into other areas can change the result (the *modifiable areal unit problem*).
- **Missing data.** Small areas often have no value because of privacy. The **n** shows how many areas remain.
- **Third factors.** Two things can go together because of a third thing (for example the age of the residents).

## 7. Using the website in your research

Do not copy the plots, maps or numbers from this site into an academic paper or report as your result. Your work is more credible when you run the analysis yourself in a program that universities and governments recognise. Use the download as a head start: it contains the data, a script and the sources.

## 8. Learn more

- Levels of measurement: [Wikipedia](https://en.wikipedia.org/wiki/Level_of_measurement)
- Correlation: [Wikipedia](https://en.wikipedia.org/wiki/Correlation) and [Spearman's rank correlation](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient)
- Correlation is not causation: [Spurious relationship](https://en.wikipedia.org/wiki/Spurious_relationship)
- Ecological fallacy: [Wikipedia](https://en.wikipedia.org/wiki/Ecological_fallacy)
- Neighbours being alike: [Spatial autocorrelation](https://en.wikipedia.org/wiki/Spatial_autocorrelation)
- Changing borders: [Modifiable areal unit problem](https://en.wikipedia.org/wiki/Modifiable_areal_unit_problem)
- Videos: [search YouTube for StatQuest "Pearson's correlation"](https://www.youtube.com/results?search_query=StatQuest+Pearson%27s+correlation) and [Spearman correlation](https://www.youtube.com/results?search_query=Spearman+rank+correlation+explained)
- Data sources: [CBS Kerncijfers wijken en buurten](https://www.cbs.nl/nl-nl/reeksen/kerncijfers-wijken-en-buurten) and [RIVM StatLine](https://statline.rivm.nl)
