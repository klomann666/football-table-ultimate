load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/json.star", "json")


#
# Football Table Ultimate
# Tronbyt / Pixlet
#
# Bundesliga 1 + 2
# Saison 2026/2027
#


API = "https://api.openligadb.de"
SEASON = "2026"

DEFAULT_LEAGUE = "bl1"
DEFAULT_FAVORITE = "FC Schalke 04"


# ------------------------------------------------------------
# Kurznamen
# ------------------------------------------------------------

SHORT_NAMES = {
    "FC Bayern München": "FCB",
    "Borussia Dortmund": "BVB",
    "RB Leipzig": "RBL",
    "VfB Stuttgart": "VFB",
    "TSG Hoffenheim": "TSG",
    "Bayer 04 Leverkusen": "B04",
    "Sport-Club Freiburg": "SCF",
    "Eintracht Frankfurt": "SGE",
    "FC Augsburg": "FCA",
    "1. FSV Mainz 05": "M05",
    "1. FC Union Berlin": "FCU",
    "Borussia Mönchengladbach": "BMG",
    "Hamburger SV": "HSV",
    "1. FC Köln": "KOE",
    "SV Werder Bremen": "SVW",
    "FC Schalke 04": "S04",
    "SV Elversberg": "ELV",
    "SC Paderborn 07": "SCP",

    "DSC Arminia Bielefeld": "DSC",
    "VfL Bochum 1848": "BOC",
    "Eintracht Braunschweig": "EBS",
    "FC Energie Cottbus": "FCE",
    "SV Darmstadt 98": "SVD",
    "SG Dynamo Dresden": "SGD",
    "SpVgg Greuther Fürth": "SGF",
    "Hannover 96": "H96",
    "1. FC Heidenheim 1846": "FCH",
    "Hertha BSC": "HER",
    "1. FC Kaiserslautern": "FCK",
    "Karlsruher SC": "KSC",
    "Holstein Kiel": "KSV",
    "1. FC Magdeburg": "FCM",
    "1. FC Nürnberg": "FCN",
    "VfL Osnabrück": "OSN",
    "FC St. Pauli": "STP",
    "VfL Wolfsburg": "WOB",
}


def short_name(name):
    if name in SHORT_NAMES:
        return SHORT_NAMES[name]

    if len(name) > 8:
        return name[:8]

    return name


# ------------------------------------------------------------
# Konfiguration
#
# WICHTIG:
# Keine schema.Generated-Funktion mehr.
# Dadurch kann Tronbyt das Schema ohne API-Aufruf laden.
# ------------------------------------------------------------

def get_schema():
    return schema.Schema(
        version="2",
        fields=[
            schema.Dropdown(
                id="league",
                name="Liga",
                desc="1. oder 2. Bundesliga",
                icon="futbol",
                default="bl1",
                options=[
                    schema.Option(
                        display="1. Bundesliga",
                        value="bl1",
                    ),
                    schema.Option(
                        display="2. Bundesliga",
                        value="bl2",
                    ),
                ],
            ),

            schema.Dropdown(
                id="favorite",
                name="Favorit",
                desc="Lieblingsverein auswählen",
                icon="star",
                default=DEFAULT_FAVORITE,
                options=[
                    # 1. Bundesliga
                    schema.Option(
                        display="FC Schalke 04",
                        value="FC Schalke 04",
                    ),
                    schema.Option(
                        display="FC Bayern München",
                        value="FC Bayern München",
                    ),
                    schema.Option(
                        display="Borussia Dortmund",
                        value="Borussia Dortmund",
                    ),
                    schema.Option(
                        display="RB Leipzig",
                        value="RB Leipzig",
                    ),
                    schema.Option(
                        display="VfB Stuttgart",
                        value="VfB Stuttgart",
                    ),
                    schema.Option(
                        display="TSG Hoffenheim",
                        value="TSG Hoffenheim",
                    ),
                    schema.Option(
                        display="Bayer 04 Leverkusen",
                        value="Bayer 04 Leverkusen",
                    ),
                    schema.Option(
                        display="Sport-Club Freiburg",
                        value="Sport-Club Freiburg",
                    ),
                    schema.Option(
                        display="Eintracht Frankfurt",
                        value="Eintracht Frankfurt",
                    ),
                    schema.Option(
                        display="FC Augsburg",
                        value="FC Augsburg",
                    ),
                    schema.Option(
                        display="1. FSV Mainz 05",
                        value="1. FSV Mainz 05",
                    ),
                    schema.Option(
                        display="1. FC Union Berlin",
                        value="1. FC Union Berlin",
                    ),
                    schema.Option(
                        display="Borussia Mönchengladbach",
                        value="Borussia Mönchengladbach",
                    ),
                    schema.Option(
                        display="Hamburger SV",
                        value="Hamburger SV",
                    ),
                    schema.Option(
                        display="1. FC Köln",
                        value="1. FC Köln",
                    ),
                    schema.Option(
                        display="SV Werder Bremen",
                        value="SV Werder Bremen",
                    ),
                    schema.Option(
                        display="SV Elversberg",
                        value="SV Elversberg",
                    ),
                    schema.Option(
                        display="SC Paderborn 07",
                        value="SC Paderborn 07",
                    ),

                    # 2. Bundesliga
                    schema.Option(
                        display="DSC Arminia Bielefeld",
                        value="DSC Arminia Bielefeld",
                    ),
                    schema.Option(
                        display="VfL Bochum 1848",
                        value="VfL Bochum 1848",
                    ),
                    schema.Option(
                        display="Eintracht Braunschweig",
                        value="Eintracht Braunschweig",
                    ),
                    schema.Option(
                        display="FC Energie Cottbus",
                        value="FC Energie Cottbus",
                    ),
                    schema.Option(
                        display="SV Darmstadt 98",
                        value="SV Darmstadt 98",
                    ),
                    schema.Option(
                        display="SG Dynamo Dresden",
                        value="SG Dynamo Dresden",
                    ),
                    schema.Option(
                        display="SpVgg Greuther Fürth",
                        value="SpVgg Greuther Fürth",
                    ),
                    schema.Option(
                        display="Hannover 96",
                        value="Hannover 96",
                    ),
                    schema.Option(
                        display="1. FC Heidenheim 1846",
                        value="1. FC Heidenheim 1846",
                    ),
                    schema.Option(
                        display="Hertha BSC",
                        value="Hertha BSC",
                    ),
                    schema.Option(
                        display="1. FC Kaiserslautern",
                        value="1. FC Kaiserslautern",
                    ),
                    schema.Option(
                        display="Karlsruher SC",
                        value="Karlsruher SC",
                    ),
                    schema.Option(
                        display="Holstein Kiel",
                        value="Holstein Kiel",
                    ),
                    schema.Option(
                        display="1. FC Magdeburg",
                        value="1. FC Magdeburg",
                    ),
                    schema.Option(
                        display="1. FC Nürnberg",
                        value="1. FC Nürnberg",
                    ),
                    schema.Option(
                        display="VfL Osnabrück",
                        value="VfL Osnabrück",
                    ),
                    schema.Option(
                        display="FC St. Pauli",
                        value="FC St. Pauli",
                    ),
                    schema.Option(
                        display="VfL Wolfsburg",
                        value="VfL Wolfsburg",
                    ),
                ],
            ),
        ],
    )


# ------------------------------------------------------------
# API
# ------------------------------------------------------------

def api_get(url, ttl):
    response = http.get(
        url,
        ttl_seconds=ttl,
    )

    if response.status_code != 200:
        return []

    return json.decode(response.body)


# ------------------------------------------------------------
# Liga
# ------------------------------------------------------------

def get_league(config):
    league = config.get(
        "league",
        DEFAULT_LEAGUE,
    )

    if league == "bl2":
        return "bl2"

    return "bl1"


def league_title(league):
    if league == "bl2":
        return "2. BUNDESLIGA"

    return "1. BUNDESLIGA"


# ------------------------------------------------------------
# Tabelle
# ------------------------------------------------------------

def get_table(league):
    return api_get(
        API
        + "/getbltable/"
        + league
        + "/"
        + SEASON,
        1800,
    )


def table_name(team):
    if "TeamName" in team:
        return team["TeamName"]

    return ""


def table_points(team):
    if "Points" in team:
        return team["Points"]

    return 0


def table_logo(team):
    if "TeamIconUrl" in team:
        return team["TeamIconUrl"]

    return ""


def favorite_position(table, favorite):
    for index, team in enumerate(table):
        if table_name(team) == favorite:
            return (
                str(index + 1)
                + ". "
                + short_name(favorite)
                + " "
                + str(table_points(team))
                + "P"
            )

    return short_name(favorite)


def table_text(table, favorite):
    if len(table) == 0:
        return "KEINE TABELLENDATEN"

    text = "TABELLE   "

    for index, team in enumerate(table):
        name = table_name(team)

        if name == "":
            continue

        marker = ""

        if name == favorite:
            marker = "*"

        text += (
            marker
            + str(index + 1)
            + " "
            + short_name(name)
            + " "
            + str(table_points(team))
            + "P   "
        )

    return text


# ------------------------------------------------------------
# Spiele
# ------------------------------------------------------------

def get_matches(league):
    return api_get(
        API
        + "/getmatchdata/"
        + league
        + "/"
        + SEASON,
        900,
    )


def home_name(game):
    return game["Team1"]["TeamName"]


def away_name(game):
    return game["Team2"]["TeamName"]


def match_finished(game):
    return game["MatchIsFinished"]


def match_datetime(game):
    return game["MatchDateTime"]


def favorite_games(games, favorite):
    matches = []

    for game in games:
        if (
            home_name(game) == favorite
            or away_name(game) == favorite
        ):
            matches.append(game)

    return matches


# ------------------------------------------------------------
# Datum / Uhrzeit
# ------------------------------------------------------------

def format_datetime(value):
    if value == None:
        return ""

    if len(value) < 16:
        return ""

    return (
        value[8:10]
        + "."
        + value[5:7]
        + "."
        + value[0:4]
        + " "
        + value[11:13]
        + ":"
        + value[14:16]
    )


# ------------------------------------------------------------
# Nächstes Spiel
# ------------------------------------------------------------

def find_next_game(games, favorite):
    matches = favorite_games(
        games,
        favorite,
    )

    next_game = None

    for game in matches:

        if match_finished(game):
            continue

        if next_game == None:
            next_game = game
            continue

        if match_datetime(game) < match_datetime(next_game):
            next_game = game

    return next_game


# ------------------------------------------------------------
# Ergebnisse
# ------------------------------------------------------------

def result_for(game):
    results = game["MatchResults"]

    if len(results) == 0:
        return None

    for result in results:
        if result["ResultTypeID"] == 2:
            return result

    return results[0]


def results_text(games, favorite):
    matches = favorite_games(
        games,
        favorite,
    )

    text = "LETZTE SPIELE   "
    count = 0

    for game in reversed(matches):

        if not match_finished(game):
            continue

        result = result_for(game)

        if result == None:
            continue

        text += (
            short_name(home_name(game))
            + " "
            + str(result["PointsTeam1"])
            + ":"
            + str(result["PointsTeam2"])
            + " "
            + short_name(away_name(game))
            + "   "
        )

        count += 1

        if count >= 3:
            break

    if count == 0:
        return "NOCH KEINE ERGEBNISSE"

    return text


# ------------------------------------------------------------
# Vereinslogo
# ------------------------------------------------------------

def favorite_logo(table, favorite):

    for team in table:

        if table_name(team) != favorite:
            continue

        url = table_logo(team)

        if url == "":
            return None

        response = http.get(
            url,
            ttl_seconds=86400,
        )

        if response.status_code != 200:
            return None

        return response.body

    return None


# ------------------------------------------------------------
# Hauptprogramm
# ------------------------------------------------------------

def main(config):

    league = get_league(config)

    favorite = config.get(
        "favorite",
        DEFAULT_FAVORITE,
    )

    table = get_table(league)

    games = get_matches(league)

    logo = favorite_logo(
        table,
        favorite,
    )

    # --------------------------------------------------------
    # Kopf
    # --------------------------------------------------------

    header = render.Column(
        main_align="center",
        children=[
            render.Text(
                content=league_title(league),
                color="#00ff00",
            ),

            render.Text(
                content=favorite_position(
                    table,
                    favorite,
                ),
                color="#00aaff",
            ),
        ],
    )

    # --------------------------------------------------------
    # Favorit + Logo
    # --------------------------------------------------------

    favorite_children = []

    if logo != None:
        favorite_children.append(
            render.Image(
                src=logo,
                width=12,
                height=12,
            )
        )

    favorite_children.append(
        render.Text(
            content=short_name(favorite),
            color="#ffffff",
        )
    )

    favorite_screen = render.Row(
        main_align="center",
        cross_align="center",
        children=favorite_children,
    )

    # --------------------------------------------------------
    # Tabelle
    # --------------------------------------------------------

    table_screen = render.Marquee(
        width=64,
        child=render.Text(
            content=table_text(
                table,
                favorite,
            ),
            color="#ffffff",
        ),
    )

    # --------------------------------------------------------
    # Ergebnisse
    # --------------------------------------------------------

    results_screen = render.Marquee(
        width=64,
        child=render.Text(
            content=results_text(
                games,
                favorite,
            ),
            color="#ffff00",
        ),
    )

    # --------------------------------------------------------
    # Nächstes Spiel
    # --------------------------------------------------------

    next_game = find_next_game(
        games,
        favorite,
    )

    if next_game == None:

        next_screen = render.Column(
            main_align="center",
            children=[
                render.Text(
                    content="KEIN SPIEL",
                    color="#ff0000",
                ),
            ],
        )

    else:

        next_screen = render.Column(
            main_align="center",
            children=[
                render.Text(
                    content="NÄCHSTES SPIEL",
                    color="#00ffff",
                ),

                render.Text(
                    content=short_name(
                        home_name(next_game)
                    )
                    + " - "
                    + short_name(
                        away_name(next_game)
                    ),
                    color="#ffffff",
                ),

                render.Text(
                    content=format_datetime(
                        match_datetime(next_game)
                    ),
                    color="#ffff00",
                ),
            ],
        )

    # --------------------------------------------------------
    # Animation
    # --------------------------------------------------------

    return render.Animation(
        children=[
            render.Root(
                delay=180,
                child=header,
            ),

            render.Root(
                delay=180,
                child=favorite_screen,
            ),

            render.Root(
                delay=120,
                child=table_screen,
            ),

            render.Root(
                delay=120,
                child=results_screen,
            ),

            render.Root(
                delay=220,
                child=next_screen,
            ),
        ],
    )