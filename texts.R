# texts.R -- all labels and "i" explanations, in English (en) and Dutch (nl).
# To change a text or add a language, edit here. Format: E(label_en, label_nl, info_en, info_nl)

E <- function(en, nl, ien, inl) list(en = en, nl = nl, ien = ien, inl = inl)

TXT <- list(
  # ---- Selection ----
  year  = E("Year", "Jaar",
            "Choose which year's numbers and map you want. Neighbourhood borders change a little every year.",
            "Kies van welk jaar je de cijfers en de kaart wilt. De grenzen van buurten veranderen elk jaar een beetje."),
  city  = E("City (municipality)", "Stad (gemeente)",
            "Type a name to search, or press 'Choose on map' and click on the map. A municipality (gemeente) is the area run by one city council.",
            "Typ een naam om te zoeken, of druk op 'Kies op kaart' en klik op de kaart. Een gemeente is het gebied van één gemeentebestuur."),
  level = E("Level", "Niveau",
            "A buurt is a small neighbourhood. A wijk is a bigger district made of several buurten. Buurten give you more dots in the plot.",
            "Een buurt is een klein stukje stad. Een wijk is groter en bestaat uit meerdere buurten. Buurten geven meer stippen in de grafiek."),
  xvar  = E("Variable X", "Variabele X",
            "The first thing you want to compare. It goes along the bottom of the plot (horizontal).",
            "Het eerste ding dat je wilt vergelijken. Het staat onderaan de grafiek (horizontaal)."),
  yvar  = E("Variable Y", "Variabele Y",
            "The second thing you want to compare. It goes up the side of the plot (vertical).",
            "Het tweede ding dat je wilt vergelijken. Het staat langs de zijkant van de grafiek (verticaal)."),
  grp_type  = E("By data type", "Op soort data",
            "Groups the variables by what kind of numbers they are (counts, percentages, ...). This matters for which statistics are allowed. See the manual, chapter on data types.",
            "Groepeert de variabelen op soort getallen (aantallen, percentages, ...). Dat is belangrijk voor welke statistiek mag. Zie de handleiding, hoofdstuk over soorten data."),
  grp_theme = E("By theme", "Op thema",
            "Groups the variables by subject, like population, income or health. The themes come from CBS and RIVM.",
            "Groepeert de variabelen op onderwerp, zoals bevolking, inkomen of gezondheid. De thema's komen van CBS en RIVM."),

  # ---- Tabs and general ----
  tab_scatter = E("Scatter plot", "Spreidingsdiagram",
            "Every dot is one buurt or wijk. If the dots roughly go up together, the two things tend to go up together. The line shows the general direction.",
            "Elke stip is één buurt of wijk. Als de stippen samen omhoog lopen, gaan de twee dingen vaak samen omhoog. De lijn laat de algemene richting zien."),
  tab_map = E("Map", "Kaart",
            "The same areas on a map with colours. The bivariate map shows both variables at once; the single map shows one.",
            "Dezelfde gebieden op een kaart met kleuren. De bivariate kaart laat beide variabelen tegelijk zien; de enkele kaart laat er één zien."),
  tab_data = E("Data and script", "Data en script",
            "Download the numbers and a ready-made script. With that you can calculate the real statistics in R or SPSS.",
            "Download de cijfers en een kant-en-klaar script. Daarmee bereken je de echte statistiek in R of SPSS."),
  style = E("Style", "Stijl",
            "Here you change how your picture looks: titles, colours and sizes. The numbers stay the same.",
            "Hier verander je hoe je plaatje eruitziet: titels, kleuren en groottes. De cijfers blijven hetzelfde."),
  lasso_sel = E("Lasso select", "Lasso-selectie",
            "A button at the top right of the plot. Press it, then draw a loop around dots with your mouse to highlight them. This helps you see which areas belong to a group. It does not change the line or the map.",
            "Een knop rechtsboven in de grafiek. Druk erop en teken met je muis een lus om stippen heen om ze te markeren. Zo zie je welke gebieden bij een groep horen. De lijn en de kaart veranderen niet."),
  lasso_desel = E("Lasso deselect", "Lasso-deselectie",
            "The opposite of lasso select. Press it and draw a loop around highlighted dots to un-highlight them.",
            "Het tegenovergestelde van lasso-selectie. Druk erop en teken een lus om gemarkeerde stippen om de markering weg te halen."),
  export = E("Export", "Exporteren",
            "Settings for the picture file you download.",
            "Instellingen voor het plaatje dat je downloadt."),

  # ---- Scatter style ----
  p_title  = E("Title", "Titel", "The big heading above the plot. Leave empty for no title.", "De grote kop boven de grafiek. Laat leeg voor geen titel."),
  p_sub    = E("Subtitle", "Subtitel", "A smaller line under the title.", "Een kleinere regel onder de titel."),
  p_x      = E("X label", "X-label", "The text under the horizontal axis. Empty = the name of the variable.", "De tekst onder de horizontale as. Leeg = de naam van de variabele."),
  p_y      = E("Y label", "Y-label", "The text next to the vertical axis. Empty = the name of the variable.", "De tekst naast de verticale as. Leeg = de naam van de variabele."),
  p_size   = E("Base font size", "Basis-lettergrootte", "Size of most text in the plot. Bigger numbers = bigger letters.", "Grootte van de meeste tekst in de grafiek. Hoger getal = grotere letters."),
  p_tsize  = E("Title size", "Titelgrootte", "Size of the title letters.", "Grootte van de letters van de titel."),
  p_family = E("Font", "Lettertype", "The style of the letters: sans (no little feet), serif (with little feet) or mono (all letters equally wide).", "De stijl van de letters: sans (zonder voetjes), serif (met voetjes) of mono (alle letters even breed)."),
  p_theme  = E("Theme", "Thema", "The overall look of the plot background and frame.", "Het algemene uiterlijk van de achtergrond en het kader van de grafiek."),
  p_grid   = E("Grid", "Raster", "The light lines in the background that help you read values.", "De lichte lijntjes op de achtergrond waarmee je waarden beter afleest."),
  p_line   = E("Regression line", "Regressielijn", "The straight line that best fits through the dots. It shows the general direction of the relationship.", "De rechte lijn die het best door de stippen past. Hij laat de algemene richting van het verband zien."),
  p_formula = E("Show regression formula", "Toon regressieformule",
                "Writes the equation of the line below the plot, in the form y = a + b x. 'a' is the value of y where the line crosses the vertical axis (x = 0). 'b' is the slope: how much y goes up (or down if negative) when x goes up by 1. x and y are the variables on the horizontal and vertical axis. It is also added to the downloaded picture.",
                "Schrijft de formule van de lijn onder de grafiek, in de vorm y = a + b x. 'a' is de waarde van y waar de lijn de verticale as snijdt (x = 0). 'b' is de helling: hoeveel y stijgt (of daalt als het negatief is) als x met 1 stijgt. x en y zijn de variabelen op de horizontale en verticale as. De formule komt ook in het gedownloade plaatje."),
  p_pcol   = E("Point colour", "Puntkleur", "Type a colour name (red) or a colour code (#2C7FB8).", "Typ een kleurnaam (red) of een kleurcode (#2C7FB8)."),
  p_lcol   = E("Line colour", "Lijnkleur", "Colour of the regression line. Same way of typing as the point colour.", "Kleur van de regressielijn. Typ het op dezelfde manier als de puntkleur."),
  p_psize  = E("Point size", "Puntgrootte", "How big the dots are.", "Hoe groot de stippen zijn."),
  p_alpha  = E("Point opacity", "Doorzichtigheid", "1 = solid dots. Lower = see-through dots, which helps when many dots lie on top of each other.", "1 = dichte stippen. Lager = doorzichtige stippen, handig als veel stippen over elkaar liggen."),

  # ---- Map style ----
  m_type = E("Map type", "Soort kaart",
             "Bivariate: shows X and Y at the same time with a grid of colours. Single variable: one colour range for one variable.",
             "Bivariaat: laat X en Y tegelijk zien met een raster van kleuren. Enkele variabele: één kleurenreeks voor één variabele."),
  m_pal  = E("Palette", "Kleurenpalet", "The set of colours used in the bivariate map. Look at the legend to see how they work.", "De kleuren die in de bivariate kaart worden gebruikt. Kijk naar de legenda om te zien hoe ze werken."),
  m_dim  = E("Classes per variable", "Klassen per variabele",
             "Each variable is cut into this many groups with equally many areas. With 3 groups you get 3 x 3 = 9 colours.",
             "Elke variabele wordt in zoveel groepen verdeeld met evenveel gebieden. Met 3 groepen krijg je 3 x 3 = 9 kleuren."),
  m_var  = E("Variable", "Variabele", "Which variable the single map shows: X or Y.", "Welke variabele de enkele kaart toont: X of Y."),
  m_spal = E("Palette", "Kleurenpalet", "The colour range of the single map.", "De kleurenreeks van de enkele kaart."),
  m_k    = E("Classes", "Klassen", "Into how many colour groups the variable is cut. Every group has about the same number of areas.", "In hoeveel kleurgroepen de variabele wordt verdeeld. Elke groep heeft ongeveer evenveel gebieden."),
  m_title  = E("Title", "Titel", "The big heading above the map. Leave empty for no title.", "De grote kop boven de kaart. Laat leeg voor geen titel."),
  m_sub    = E("Subtitle", "Subtitel", "A smaller line under the title.", "Een kleinere regel onder de titel."),
  m_size   = E("Base font size", "Basis-lettergrootte", "Size of most text on the map.", "Grootte van de meeste tekst op de kaart."),
  m_lsize  = E("Legend text size", "Grootte legendatekst", "Size of the text in the legend. Make it smaller if long names do not fit.", "Grootte van de tekst in de legenda. Maak hem kleiner als lange namen niet passen."),
  m_tsize  = E("Title size", "Titelgrootte", "Size of the title letters.", "Grootte van de letters van de titel."),
  m_bw     = E("Border width (0 = none)", "Randdikte (0 = geen)", "How thick the lines between the areas are. 0 removes them.", "Hoe dik de lijnen tussen de gebieden zijn. 0 haalt ze weg."),
  m_bcol   = E("Border colour", "Randkleur", "Colour of the lines between the areas.", "Kleur van de lijnen tussen de gebieden."),

  # ---- Export and downloads ----
  ex_w   = E("Width (cm)", "Breedte (cm)", "How wide the saved picture is, in centimetres.", "Hoe breed het opgeslagen plaatje is, in centimeters."),
  ex_h   = E("Height (cm)", "Hoogte (cm)", "How tall the saved picture is, in centimetres.", "Hoe hoog het opgeslagen plaatje is, in centimeters."),
  ex_dpi = E("DPI (sharpness)", "DPI (scherpte)", "Tiny dots per inch in the saved picture. 300 is good for printing, 150 for screens.", "Kleine puntjes per inch in het opgeslagen plaatje. 300 is goed voor afdrukken, 150 voor schermen."),
  ex_fmt = E("Format", "Bestandstype", "PNG = a normal picture. SVG = stays sharp at any size and can be edited in drawing programs. PDF = good for documents.", "PNG = een gewoon plaatje. SVG = blijft scherp op elke grootte en is te bewerken in tekenprogramma's. PDF = goed voor documenten."),
  script_lang = E("Script for", "Script voor", "A script is a text file with computer instructions that does the calculations for you. Choose the program you use: R or SPSS.", "Een script is een tekstbestand met computerinstructies dat de berekeningen voor je doet. Kies het programma dat je gebruikt: R of SPSS."),
  pack = E("Analysis package", "Analysepakket", "A zip file with the data (csv), the shapes (gpkg), a file that explains the sources and variables, and the script.", "Een zipbestand met de data (csv), de vormen van de gebieden (gpkg), een bestand met uitleg over bronnen en variabelen, en het script.")
)

# ---- Data types ----
DTYPES <- list(
  count = list(
    name  = c(en = "Counts", nl = "Aantallen"),
    level = c(en = "ratio scale, discrete", nl = "ratio-schaal, discreet"),
    info  = c(en = "Whole numbers you count, like inhabitants or houses. Zero really means 'none'. Big areas have big counts, so counts mostly measure how big an area is. Percentages or rates are often a fairer choice.",
              nl = "Hele getallen die je telt, zoals inwoners of woningen. Nul betekent echt 'geen'. Grote gebieden hebben grote aantallen, dus aantallen meten vooral hoe groot een gebied is. Percentages of verhoudingen zijn vaak eerlijker.")),
  share = list(
    name  = c(en = "Percentages", nl = "Percentages"),
    level = c(en = "ratio scale, 0-100%", nl = "ratio-schaal, 0-100%"),
    info  = c(en = "A part out of a whole, like the percentage of people over 65. Fair for comparing areas of different size. It can never go below 0 or above 100.",
              nl = "Een deel van een geheel, zoals het percentage 65-plussers. Eerlijk voor het vergelijken van gebieden van verschillende grootte. Het kan nooit onder 0 of boven 100 komen.")),
  rate = list(
    name  = c(en = "Rates and densities", nl = "Dichtheden en verhoudingen"),
    level = c(en = "ratio scale", nl = "ratio-schaal"),
    info  = c(en = "Something per unit, like inhabitants per km2 or cases per 1,000 people. Also fair across areas of different size, but very crowded areas can be extreme outliers.",
              nl = "Iets per eenheid, zoals inwoners per km2 of gevallen per 1.000 mensen. Ook eerlijk tussen gebieden van verschillende grootte, maar zeer drukke gebieden kunnen extreme uitschieters zijn.")),
  amount = list(
    name  = c(en = "Amounts and averages", nl = "Bedragen en gemiddelden"),
    level = c(en = "ratio or interval scale", nl = "ratio- of intervalschaal"),
    info  = c(en = "Measured quantities such as average income (euro) or distance (km). Averages hide differences inside an area, and a few very high values can pull the average up.",
              nl = "Gemeten hoeveelheden zoals gemiddeld inkomen (euro) of afstand (km). Gemiddelden verbergen verschillen binnen een gebied, en een paar hele hoge waarden trekken het gemiddelde omhoog.")),
  ordinal = list(
    name  = c(en = "Ordered classes", nl = "Geordende klassen"),
    level = c(en = "ordinal scale", nl = "ordinale schaal"),
    info  = c(en = "Classes with an order but unequal gaps, like urbanity from 1 to 5. Use rank correlation (Spearman) instead of Pearson, and read the regression line with care.",
              nl = "Klassen met een volgorde maar ongelijke afstanden, zoals stedelijkheid van 1 tot 5. Gebruik rangcorrelatie (Spearman) in plaats van Pearson en lees de regressielijn voorzichtig.")),
  other = list(
    name  = c(en = "Other / unknown", nl = "Overig / onbekend"),
    level = c(en = "unknown", nl = "onbekend"),
    info  = c(en = "The type could not be found automatically. Read the definition (i) before you use this variable.",
              nl = "Het soort kon niet automatisch worden bepaald. Lees de definitie (i) voordat je deze variabele gebruikt."))
)
