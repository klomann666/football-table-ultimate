load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("encoding/json.star", "json")

API = "https://api.openligadb.de"

SEASON = "2026"

DEFAULT_LEAGUE = "bl1"
DEFAULT_FAVORITE = "FC Schalke 04"


SHORT_NAMES = {
    "FC Bayern MÃ¼nchen": "FCB",
    "Borussia Dortmund": "BVB",
    "Bayer 04 Leverkusen": "B04",
    "RB Leipzig": "RBL",
    "VfB Stuttgart": "VFB",
    "Eintracht Frankfurt": "SGE",
    "SC Freiburg": "SCF",
    "1. FSV Mainz 05": "M05",
    "FC Augsburg": "FCA",
    "1. FC Union Berlin": "FCU",
    "Borussia MÃ¶nchengladbach": "BMG",
    "TSG 1899 Hoffenheim": "TSG",
    "Hamburger SV": "HSV",
    "FC Schalke 04": "S04",
    "SV Werder Bremen": "SVW",
    "1. FC KÃ¶ln": "KOE",

    "VfL Bochum 1848": "BOC",
    "Hertha BSC": "HER",
    "Hannover 96": "H96",
    "1. FC Kaiserslautern": "FCK",
    "Karlsruher SC": "KSC",
    "1. FC NÃ¼rnberg": "FCN",
    "SC Paderborn 07": "SCP",
    "SV Darmstadt 98": "SVD",
    "SpVgg Greuther FÃ¼rth": "SGF",
    "Eintracht Braunschweig": "EBS",
    "1. FC Magdeburg": "FCM",
    "Holstein Kiel": "KSV",
    "SV Elversberg": "ELV",
}


def short_name(name):
    if name in SHORT_NAMES:
        return SHORT_NAMES[name]

    if len(name) > 8:
        return name[:8]

    return name


def api_get(url, ttl):
    response = http.get(
        url,
        ttl_seconds=ttl,
    )

    if response.status_code != 200:
        return []

    return json.decode(response.body)


def get_league(config):
    league = config.get(
        "league",
        DEFAULT_LEAGUE,
    )

    if league == "bl2":
        return "bl2"

    return "bl1"


def get_teams(league):
    return api_get(
        API
        + "/getavailableteams/"
        + league
        + "/"
        + SEASON,
        86400,
    )


def team_name(team):
    if "TeamName" in team:
        return team["TeamName"]

    return ""


def favorite_options(league):
    options = []

    teams = get_teams(league)

    for team in teams:
        name = team_name(team)

        if name == "":
            continue

        options.append(
            schema.Option(
                display=short_name(name),
                value=name,
            )
        )

    default = DEFAULT_FAVORITE

    if league == "bl2":
        default = "VfL Bochum 1848"

    if len(options) > 0:
        found = False

        for option in options:
            if option.value == default:
                found = True

        if not found:
            default = options[0].value

    return [
        schema.Dropdown(
            id="favorite",
            name="Favorit",
            desc="Lieblingsverein",
            icon="star",
            default=default,
            options=options,
        ),
    ]


def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Dropdown(
                id="league",
                name="Liga",
                desc="Bundesliga auswaehlen",
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

            schema.Generated(
                id="favorite",
                source="league",
                handler=favorite_options,
            ),
        ],
    )


def get_table(league):
    return api_get(
        API
        + "/getbltable/"
        + league
        + "/"
        + SEASON,
        1800,
    )


def get_matches(league):
    return api_get(
        API
        + "/getmatchdata/"
        + league
        + "/"
        + SEASON,
        900,
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


def home_name(game):
    return game["Team1"]["TeamName"]


def away_name(game):
    return game["Team2"]["TeamName"]


def match_finished(game):
    return game["MatchIsFinished"]


def match_datetime(game):
    return game["MatchDateTime"]


def favorite_games(games, favorite):
    result = []

    for game in games:
        if (
            home_name(game) == favorite
            or away_name(game) == favorite
        ):
            result.append(game)

    return result


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


def find_next_game(games, favorite):
    matches = favorite_games(
        games,
        favorite,
    )

    for game in matches:
        if not match_finished(game):
            return game

    return None


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

    text = "ERGEBNISSE   "
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

    if league == "bl1":
        title = "1. BUNDESLIGA"
    else:
        title = "2. BUNDESLIGA"

    header = render.Column(
        children=[
            render.Text(
                content=title,
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

    favorite_content = []

    if logo != None:
        favorite_content.append(
            render.Image(
                src=logo,
                width=12,
                height=12,
            )
        )

    favorite_content.append(
        render.Text(
            content=short_name(favorite),
            color="#ffffff",
        )
    )

    favorite_screen = render.Row(
        main_align="center",
        cross_align="center",
        children=favorite_content,
    )

    next_game = find_next_game(
        games,
        favorite,
    )

    if next_game == None:
        next_screen = render.Text(
            content="KEIN NAECHSTES SPIEL",
            color="#ff0000",
        )
    else:
        next_screen = render.Column(
            main_align="center",
            cross_align="center",
            children=[
                render.Text(
                    content="NAECHSTES SPIEL",
                    color="#00ffff",
                ),

                render.Text(
                    content=short_name(
                        home_name(next_game)
                    )
                    + "-"
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
                child=render.Marquee(
                    width=64,
                    child=render.Text(
                        content=table_text(
                            table,
                            favorite,
                        ),
                        color="#ffffff",
                    ),
                ),
            ),

            render.Root(
                delay=120,
                child=render.Marquee(
                    width=64,
                    child=render.Text(
                        content=results_text(
                            games,
                            favorite,
                        ),
                        color="#ffff00",
                    ),
                ),
            ),

            render.Root(
                delay=220,
                child=next_screen,
            ),
        ],
    )
