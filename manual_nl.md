## 1. Wat is deze website?

Buurt Explorer helpt je om patronen te zoeken tussen twee variabelen in Nederlandse buurten. Bijvoorbeeld: hebben buurten met een hoger inkomen ook gezondere mensen? Jij kiest twee dingen en de website maakt een **spreidingsdiagram** en een **kleurenkaart**.

De website is bedoeld als inspiratie en beginpunt. Gebruik hem om ideeën op te doen en controleer ze daarna zelf goed (zie hoofdstuk 7).

## 2. Snel beginnen

1. Kies links een **jaar**, een **stad** en een **niveau** (buurt of wijk).
2. Kies **Variabele X** en **Variabele Y**. Typ een woord om te zoeken, of druk op *Bladeren door variabelen*.
3. Kijk op het tabblad **Spreidingsdiagram**. Elke stip is één gebied.
4. Open het tabblad **Kaart** om dezelfde gebieden op een kaart te zien.
5. Pas het uiterlijk aan met het paneel **Stijl** rechts.
6. Bewaar je plaatje met *Download*, of ga naar **Data en script** voor de cijfers.

De taalknop (NL | EN) en deze handleiding staan altijd rechtsboven. Elke kleine **i** opent een korte uitleg.

## 3. Filters

**Jaar.** Van welk jaar je de cijfers en grenzen gebruikt. De grenzen van buurten veranderen elk jaar een beetje, dus cijfers en kaart komen altijd uit hetzelfde jaar.

**Stad.** Typ een naam, of druk op *Kies op kaart* en klik je stad aan op de kaart van Nederland. Bovenaan die kaart kun je ook zoeken. Beweeg je muis over een gemeente om de naam te zien.

**Niveau.** Een *buurt* is een klein stukje stad. Een *wijk* is groter en bestaat uit meerdere buurten.

**Variabele X en Y.** De twee dingen die je vergelijkt. X staat onderaan, Y staat langs de zijkant. Druk op *Bladeren door variabelen* om ze allemaal te zien, gegroepeerd **op thema** (het onderwerp, zoals inkomen of gezondheid) of **op soort data** (wat voor getallen het zijn). De **i** naast een variabele vertelt wat het betekent en wat voor soort data het is. De tekst onder het vak toont het soort van je huidige keuze.

**Spreidingsdiagram.** Eén stip per gebied. De lijn is de *regressielijn*: de rechte lijn die het best door de stippen past. De **n** onderaan is het aantal gebieden in de grafiek. Gebieden zonder waarde voor X of Y worden weggelaten. Beweeg je muis over een stip om te zien welk gebied het is.

**Lasso-selectie / deselectie.** Twee knoppen rechtsboven in de grafiek. Met *lasso-selectie* teken je een lus om stippen om ze te markeren. Met *lasso-deselectie* haal je de markering weg.De lijn en de kaart veranderen niet.

**Kaart.** Dezelfde gebieden met kleuren.
- *Bivariaat*: beide variabelen tegelijk. Een kleurenraster van 3 x 3: licht = laag op beide, donker = hoog op beide, en de gemengde kleuren laten zien waar de één hoog is en de ander laag.
- *Enkele variabele*: één kleurenreeks voor X of Y.
- Grijze gebieden hebben geen data. Beweeg je muis over een gebied om de naam en de waarden te zien.

**Stijl.** Verandert hoe het plaatje eruitziet (titels, kleuren, groottes, randen). De cijfers veranderen nooit. Laat een vak leeg om de standaardwaarde te gebruiken.

**Exporteren.** Breedte en hoogte in centimeters, DPI (scherpte; 300 voor afdrukken, 150 voor schermen) en het bestandstype (PNG, SVG of PDF).

**Data en script.** Downloadt een zipbestand met: de data (`data.csv`), de vormen van de gebieden (`areas.gpkg`), een tekstbestand met bronnen en uitleg over de variabelen (`README_metadata.txt`) en een script voor **R** of **SPSS** dat de echte statistiek voor je uitvoert.

## 4. Een spreidingsdiagram lezen

- Stippen die van links naar rechts omhoog lopen: als X hoger is, is Y meestal ook hoger (*positief* verband).
- Stippen die omlaag lopen: als X hoger is, is Y meestal lager (*negatief* verband).
- Stippen in een wolk zonder richting: geen duidelijk verband.
- Hoe dichter de stippen om de lijn zitten, hoe sterker het verband.

Een verband is geen bewijs dat het ene ding het andere *veroorzaakt*: Ijsverkoop en zonnebrand gaan samen omhoog, maar ijs veroorzaakt geen zonnebrand: de zon doet dat.

## 5. Welke soort data kun je gebruiken?

Niet alle getallen zijn hetzelfde. Statistici noemen dit het 'meetniveau'.

| Soort | Wat het is | Voorbeeld | Correlatie toegestaan? |
|---|---|---|---|
| **Nominaal** (categorieën) | Namen zonder volgorde | Soort gebied: stad, dorp | Nee. Vergelijk in plaats daarvan groepen. Dit wordt niet hier aangeboden. |
| **Ordinaal** (geordende klassen) | Volgorde, maar ongelijke afstanden | Stedelijkheid 1 tot 5 | Rangcorrelatie (Spearman). Niet Pearson. |
| **Interval** | Gelijke afstanden, nul is willekeurig | Temperatuur in graden Celsius | Ja. |
| **Ratio** | Gelijke afstanden, nul betekent 'geen' | Inkomen, leeftijd, afstand, aantallen, percentages | Ja. |

Bijna alle variabelen hier zijn **ratio**-variabelen, verdeeld in vier groepen:

- **Aantallen** (inwoners, woningen). Let op: grote gebieden hebben van alles grote aantallen. Twee aantallen correleren dus bijna altijd, simpelweg omdat beide meegroeien met de grootte van het gebied. Dit heet het *grootte-effect*. Kies liever percentages of verhoudingen.
- **Percentages** (aandeel 65-plussers). Betrouwbaar tussen gebieden van verschillende grootte. Ze blijven tussen 0 en 100, en percentages die samen een geheel vormen (zoals leeftijdsgroepen) trekken elkaar naar beneden.
- **Dichtheden en verhoudingen** (inwoners per km2). Betrouwbaar, maar een paar zeer drukke gebieden kunnen extreme uitschieters zijn.
- **Bedragen en gemiddelden** (gemiddeld inkomen). Gemiddelden verbergen verschillen binnen een gebied. Sterk scheve data (zoals inkomen) ziet er vaak beter uit na een logaritme-transformatie, of je gebruikt Spearman.

### Combinaties en wat ze betekenen

| X en Y | Wat te doen |
|---|---|
| Ratio en ratio | Pearson-correlatie is prima. Kijk in de grafiek naar uitschieters en kromme patronen. Spearman is een veilig alternatief. |
| Ratio en ordinaal | Gebruik Spearman. |
| Ordinaal en ordinaal | Gebruik Spearman of Kendall. |
| Aantal en aantal | Wees wantrouwend: waarschijnlijk het grootte-effect. Schakel over op percentages of verhoudingen. |
| Alles met een nominale variabele | Correlatie werkt niet. Vergelijk groepen (bijvoorbeeld met een t-toets of ANOVA). |

**Het gevolg van een verkeerde keuze: er komt wel een getal uit, maar het betekent niets of wijst de verkeerde kant op. De grafiek tekent altijd een rechte lijn, ook als die niet past. Kijk dus altijd naar de stippen, niet alleen naar de lijn.**

## 6. Valkuilen

- **Ecologische denkfout.** Een patroon tussen gebieden geldt niet voor individuele mensen. Een rijke buurt met gezonde mensen betekent niet dat rijke individuen gezonder zijn.
- **Buren lijken op elkaar.** Buurten naast elkaar lijken vaak op elkaar (*ruimtelijke autocorrelatie*). Je stippen zijn niet echt onafhankelijk, waardoor de toetsen resultaten zekerder doen lijken dan ze zijn.
- **Grenzen doen ertoe.** Als je de kaart anders in gebieden verdeelt, kan de uitkomst veranderen (het *modifiable areal unit problem*).
- **Ontbrekende data.** Kleine gebieden hebben vaak geen waarde vanwege privacy. De **n** toont hoeveel gebieden overblijven.
- **Derde factoren.** Twee variabelen kunnen samengaan door een derde variabel die ook invloed op één of beide uitoefend (bijvoorbeeld educatie. Gezonde leefstijl (niet roken en sporten) samen met inkomen heeft een positief verband, dit echter veroorzaakt door een hogere educatie die met beide variabelen een positief verband heeft).

## 7. De website gebruiken voor onderzoek

Neem de grafieken, kaarten of getallen van deze site niet over in een wetenschappelijk artikel of rapport als jouw resultaat. Je werk is geloofwaardiger als je de analyse zelf uitvoert in een programma dat universiteiten en overheden erkennen. Gebruik de download als voorsprong: hij bevat de data, een script en de bronnen.

## 8. Meer leren

De meeste pagina's hieronder zijn in het Engels.

- Meetniveaus: [Wikipedia](https://en.wikipedia.org/wiki/Level_of_measurement)
- Correlatie: [Wikipedia](https://en.wikipedia.org/wiki/Correlation) en [Spearman-rangcorrelatie](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient)
- Correlatie is geen oorzaak: [Schijnverband (Spurious relationship)](https://en.wikipedia.org/wiki/Spurious_relationship)
- Ecologische denkfout: [Wikipedia](https://en.wikipedia.org/wiki/Ecological_fallacy)
- Buren die op elkaar lijken: [Spatial autocorrelation](https://en.wikipedia.org/wiki/Spatial_autocorrelation)
- Veranderende grenzen: [Modifiable areal unit problem](https://en.wikipedia.org/wiki/Modifiable_areal_unit_problem)
- Video's: [zoek op YouTube naar correlatie uitgelegd](https://www.youtube.com/results?search_query=correlatie+uitgelegd) en [StatQuest Pearson's correlation](https://www.youtube.com/results?search_query=StatQuest+Pearson%27s+correlation)
- Databronnen: [CBS Kerncijfers wijken en buurten](https://www.cbs.nl/nl-nl/reeksen/kerncijfers-wijken-en-buurten) en [RIVM StatLine](https://statline.rivm.nl)
