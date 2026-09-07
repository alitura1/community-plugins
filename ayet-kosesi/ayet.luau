--!nonstrict

-- Ayet Köşesi
-- A Noctalia desktop widget powered by Akıl Kuran's public
-- /api/daily-verse endpoint.

local DAILY_API = "https://akilkuran.com/api/daily-verse"
local LOGO_URL = "https://akilkuran.com/apple-touch-icon.png?v=3"

local verse = nil
local loading = false
local mealReadInProgress = false
local lastReference = nil
local lastMealId = nil
local lastLanguage = nil

local dataFile = nil
local logoFile = nil
local logoStateFile = nil
local logoLoading = false
local lastLogoDay = nil

local function todayKey()
    return os.date("%Y-%j")
end

local function homePath()
    local home = noctalia.getenv("HOME")
    if home == nil or home == "" then
        return nil
    end
    return home
end

local function readConfiguredMealId()
    local home = homePath()
    if home == nil then
        return nil
    end

    local path = home .. "/.config/ayet-kosesi/meal-id"
    local raw = noctalia.readFile(path)

    if raw == nil then
        return nil
    end

    local cleaned = tostring(raw):gsub("^%s+", ""):gsub("%s+$", "")
    local id = tonumber(cleaned)

    if id ~= nil and id > 0 then
        return math.floor(id)
    end

    return nil
end

local function systemLanguage()
    local names = { "LC_ALL", "LC_MESSAGES", "LANG" }

    for _, name in ipairs(names) do
        local value = noctalia.getenv(name)

        if value ~= nil and value ~= "" then
            value = tostring(value):lower()
            value = value:gsub("%..*$", "")
            value = value:gsub("@.*$", "")
            value = value:gsub("_", "-")

            local lang = value:match("^([a-z][a-z])")
            if lang ~= nil then
                return lang
            end
        end
    end

    return "en"
end

local DEFAULT_AUTHOR_BY_LANGUAGE = {
    tr = 105,
    en = 32,
}

local function fallbackMealId(language)
    return DEFAULT_AUTHOR_BY_LANGUAGE[language]
end

local function resolveMealId(callback)
    local configured = readConfiguredMealId()
    if configured ~= nil then
        callback(configured)
        return
    end

    local home = homePath()
    if home == nil then
        callback(nil)
        return
    end

    local helper = home .. "/.local/bin/akilkuran-meal-id"

    if mealReadInProgress then
        return
    end

    mealReadInProgress = true

    local accepted = noctalia.runAsync(
        { helper },
        function(result)
            mealReadInProgress = false

            local id = nil

            if result ~= nil and result.exitCode == 0 then
                local out = tostring(result.stdout or "")
                    :gsub("^%s+", "")
                    :gsub("%s+$", "")
                local parsed = tonumber(out)

                if parsed ~= nil and parsed > 0 then
                    id = math.floor(parsed)
                end
            end

            callback(id)
        end
    )

    if not accepted then
        mealReadInProgress = false
        callback(nil)
    end
end

local function saveVerse(key)
    if dataFile == nil or verse == nil then
        return
    end

    local encoded = noctalia.json.encode({
        day = key,
        mealId = lastMealId,
        language = lastLanguage,
        reference = lastReference,
        verse = verse,
    })

    if encoded ~= nil then
        noctalia.writeFile(dataFile, encoded)
    end
end

local function loadCachedVerse()
    if dataFile == nil then
        return
    end

    local raw = noctalia.readFile(dataFile)
    if raw == nil then
        return
    end

    local decoded = noctalia.json.decode(raw)
    if decoded == nil or decoded.verse == nil then
        return
    end

    verse = decoded.verse
    lastMealId = tonumber(decoded.mealId)
    lastLanguage = decoded.language
    lastReference = decoded.reference

    if lastReference == nil and verse.url ~= nil then
        lastReference = tostring(verse.url):match(
            "akilkuran%.com/(%d+/%d+)"
        )
    end
end

local function saveLogoState(key)
    if logoStateFile == nil then
        return
    end

    local encoded = noctalia.json.encode({ day = key })
    if encoded ~= nil then
        noctalia.writeFile(logoStateFile, encoded)
    end
end

local function loadLogoState()
    if logoStateFile == nil then
        return
    end

    local raw = noctalia.readFile(logoStateFile)
    if raw == nil then
        return
    end

    local decoded = noctalia.json.decode(raw)
    if decoded ~= nil then
        lastLogoDay = decoded.day
    end
end

local function render()
    local WIDTH = 420
    local HEIGHT = 260

    if verse == nil then
        desktopWidget.render(
            ui.column(
                {
                    width = WIDTH,
                    height = HEIGHT,
                    gap = 14,
                    padding = 22,
                    fill = "surface_variant/0.82",
                    radius = 20,
                    justify = "center",
                    align = "stretch",
                },
                {
                    ui.row(
                        { gap = 10, align = "center" },
                        {
                            ui.glyph({
                                name = "book",
                                size = 22,
                                color = "primary",
                            }),
                            ui.label({
                                text = "AYET KÖŞESİ",
                                fontSize = 18,
                                fontWeight = "bold",
                                color = "primary",
                            }),
                        }
                    ),
                    ui.label({
                        text = loading
                            and "Ayet alınıyor…"
                            or "Akıl Kuran'dan günlük ayet",
                        fontSize = 15,
                        color = "on_surface",
                        maxWidth = 370,
                    }),
                }
            )
        )
        return
    end

    local headerChildren = {
        ui.row(
            { gap = 10, align = "center", flexGrow = 1 },
            {
                ui.glyph({
                    name = "book",
                    size = 22,
                    color = "primary",
                }),
                ui.label({
                    text = "AYET KÖŞESİ",
                    fontSize = 18,
                    fontWeight = "bold",
                    color = "primary",
                }),
            }
        ),
    }

    local rightChildren = {}

    if logoFile ~= nil then
        table.insert(rightChildren, ui.image({
            path = logoFile,
            width = 30,
            height = 30,
        }))
    end

    table.insert(rightChildren, ui.label({
        text = verse.surah .. " " .. tostring(verse.number),
        fontSize = 13,
        fontWeight = "bold",
        color = "on_surface_variant",
    }))

    table.insert(
        headerChildren,
        ui.row(
            { gap = 8, align = "center" },
            rightChildren
        )
    )

    desktopWidget.render(
        ui.column(
            {
                width = WIDTH,
                height = HEIGHT,
                gap = 12,
                padding = 20,
                fill = "surface_variant/0.82",
                radius = 20,
                justify = "start",
                align = "stretch",
            },
            {
                ui.row(
                    {
                        gap = 8,
                        align = "center",
                        justify = "space_between",
                    },
                    headerChildren
                ),

                ui.separator({
                    thickness = 1,
                    color = "outline",
                    spacing = 2,
                }),

                ui.markdown({
                    text = "**“" .. verse.text .. "”**",
                    width = 380,
                    height = 135,
                }),

                ui.row(
                    {
                        gap = 10,
                        align = "center",
                        justify = "space_between",
                    },
                    {
                        ui.label({
                            text = verse.author,
                            fontSize = 12,
                            color = "on_surface_variant",
                            maxWidth = 180,
                        }),
                        ui.button({
                            text = "Akıl Kuran'da aç",
                            variant = "secondary",
                            controlSize = "sm",
                            onClick = "openVerse",
                        }),
                    }
                ),
            }
        )
    )
end


local function fetchDailyVerse(key, mealId, language)
    if loading then
        return
    end

    loading = true
    render()

    local url = DAILY_API

    if mealId ~= nil and mealId > 0 then
        url = url .. "?author=" .. tostring(mealId)
    end

    local accepted = noctalia.http(
        {
            url = url,
            method = "GET",
            headers = {
                "Accept: application/json",
            },
        },
        function(response)
            loading = false

            if not response.ok
                or response.status < 200
                or response.status >= 300 then
                noctalia.log(
                    "Ayet Köşesi Günün Ayeti API hatası: "
                    .. tostring(response.status)
                )
                render()
                return
            end

            local decoded, err = noctalia.json.decode(response.body)
            if decoded == nil then
                noctalia.log(
                    "Ayet Köşesi API JSON çözülemedi: " .. tostring(err)
                )
                render()
                return
            end

            local data = decoded.data
            if data == nil
                or data.surahId == nil
                or data.verseNum == nil
                or data.translation == nil then
                noctalia.log("Ayet Köşesi API beklenen veriyi döndürmedi.")
                render()
                return
            end

            local surahId = tonumber(data.surahId)
            local verseNumber = tonumber(data.verseNum)
            if surahId == nil or verseNumber == nil
                or surahId < 1 or verseNumber < 1 then
                noctalia.log("Ayet Köşesi API ayet referansı geçersiz.")
                render()
                return
            end

            local translation = data.translation
            local author = translation.author or {}
            local reference = tostring(data.ref or (
                tostring(surahId) .. ":" .. tostring(verseNumber)
            ))

            verse = {
                surah = tostring(data.surahName or "?"),
                number = verseNumber,
                text = tostring(translation.text or ""),
                author = tostring(translation.authorName or author.name or ""),
                url = tostring(data.url or (
                    "https://akilkuran.com/"
                    .. tostring(surahId)
                    .. "/"
                    .. tostring(verseNumber)
                )),
            }

            lastReference = reference
            lastMealId = tonumber(translation.authorId)
                or tonumber(author.id)
                or mealId
            lastLanguage = tostring(
                translation.language
                    or author.language
                    or language
                    or ""
            )

            saveVerse(key)
            render()
        end
    )

    if not accepted then
        loading = false
        noctalia.log("Ayet Köşesi Günün Ayeti isteği başlatılamadı.")
        render()
    end
end

local function refreshLogo(key)
    if logoFile == nil or logoLoading then
        return
    end

    logoLoading = true

    local accepted = noctalia.runAsync(
        {
            "curl",
            "-fsSL",
            "--connect-timeout",
            "10",
            "--max-time",
            "20",
            "-o",
            logoFile,
            LOGO_URL,
        },
        function(result)
            logoLoading = false

            if result ~= nil and result.exitCode == 0 then
                lastLogoDay = key
                saveLogoState(key)
                render()
            else
                noctalia.log(
                    "Ayet Köşesi logosu güncellenemedi; cache korunuyor."
                )
            end
        end
    )

    if not accepted then
        logoLoading = false
    end
end

function openVerse()
    if verse == nil or verse.url == nil then
        return
    end

    noctalia.runAsync(
        { "xdg-open", verse.url },
        nil
    )
end

function update()
    noctalia.setUpdateInterval(60000)

    local key = todayKey()

    if dataFile == nil then
        local dir = noctalia.pluginDataDir()

        if dir == nil then
            render()
            return
        end

        dataFile = dir .. "/verse.json"
        logoFile = dir .. "/akilkuran-logo.png"
        logoStateFile = dir .. "/logo.json"

        loadCachedVerse()
        loadLogoState()
    end

    if lastLogoDay ~= key then
        refreshLogo(key)
    end

    local language = systemLanguage()
    resolveMealId(function(explicitMealId)
        local currentKey = todayKey()
        local mealId = explicitMealId or fallbackMealId(language)

        -- Poll the public API every minute. The API itself follows Akıl Kuran's
        -- real automatic/manual Günün Ayeti logic and handles its own caching.
        fetchDailyVerse(currentKey, mealId, language)
    end)

    render()
end

update()
