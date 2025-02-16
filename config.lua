Config = {}

Config.Command = 'support' -- Commando om het support menu te openen
Config.Key = 'F9' -- Toets om het support menu te openen
Config.Title = 'Test Support' -- Titel die wordt getoond in het support venster
Config.EnableKeyMapping = true -- Schakel key mapping voor het commando in/uit

-- Server Informatie
Config.ServerInfo = {
    Name = "Jouw Server Naam", -- Server naam
    Description = "Jouw server beschrijving", -- Korte server beschrijving
    MaxSlots = 64, -- Maximaal aantal spelers
    Website = "https://jouwwebsite.nl", -- Server website
    Discord = "https://discord.gg/jouwserver", -- Discord uitnodiging
    Features = { -- Lijst met server functies
        "Aangepaste auto's",
        "Aangepaste banen",
        "Economisch systeem",
        "Huizensysteem"
    },
    Rules = { -- Server regels
        "Wees respectvol naar alle spelers",
        "Geen vals spelen of exploiten",
        "Geen intimidatie of pesten",
        "Volg de RP-richtlijnen",
        "Blijf in karakter",
        "Gebruik gezond verstand"
    },
    Locations = { -- Belangrijke server locaties met coördinaten
        ['Politiebureau'] = {
            coords = vector3(442.5, -983.0, 30.7),
            blip = {sprite = 60, color = 29} -- Blip configuratie
        },
        ['Ziekenhuis'] = {
            coords = vector3(294.6, -1448.2, 29.9),
            blip = {sprite = 61, color = 2}
        },
        ['Gemeentehuis'] = {
            coords = vector3(-544.9, -204.4, 38.2),
            blip = {sprite = 419, color = 0}
        },
        ['Legion Square'] = {
            coords = vector3(195.2, -934.4, 30.7),
            blip = {sprite = 492, color = 0}
        },
        ['Vliegveld'] = {
            coords = vector3(-1037.5, -2968.1, 13.9),
            blip = {sprite = 90, color = 3}
        }
    },
    GameMode = "Roleplay", -- Server spelmodus
    Language = "Nederlands", -- Primaire server taal
    Whitelist = false, -- Of de server een whitelist heeft
    AntiCheat = true, -- Of de server anti-cheat gebruikt
    CustomScripts = { -- Lijst met belangrijke aangepaste scripts/functies
        "Aangepast banensysteem",
        "Geavanceerd huizensysteem",
        "Bendesysteem",
        "Drugssysteem"
    }
}

Config.AIMemory = {
    EnableServerInfo = true, -- Of de bot server info moet kennen
    EnableBlipTracking = true, -- Of de bot blips moet volgen en kennen
    EnableRules = true, -- Of de bot regels moet kennen
    EnableFeatures = true, -- Of de bot functies moet kennen
    EnableLocations = true, -- Of de bot locaties moet kennen
    EnableFAQ = true,  -- Of de bot FAQ kennis moet gebruiken
    RulesDetail = {
        ShowPunishments = true, -- Of strafinformatie in reacties moet worden opgenomen
        ShowAppeals = true,    -- Of beroepinformatie in reacties moet worden opgenomen
        DetailLevel = 2        -- 1: Basis, 2: Gedetailleerd, 3: Volledig detail met voorbeelden
    }
}

Config.RestrictedInfo = {
    'adminlist',
    'passwords',
    'security',
    'backend',
}

Config.Locale = {
    ['command_desc'] = 'Open AI Support menu',
    ['menu_opened'] = 'Support menu geopend',
    ['menu_closed'] = 'Support menu gesloten',
}

-- Categorieën voor bugrapporten
Config.BugCategories = {
    'Gameplay',
    'Voertuig',
    'Map',
    'UI/HUD',
    'Prestatie',
    'Overig'
}

-- Veelgestelde Vragen
Config.FAQ = {
    -- Formaat: { question = "Vraag hier", answer = "Antwoord hier" }
    {
        question = "Hoe krijg ik een baan?",
        answer = "Je kunt een baan krijgen door het arbeidsbureau bij Legion Square te bezoeken. Zoek naar het aktentas-icoon op je kaart. Beschikbare banen zijn onder andere taxichauffeur, bezorger en meer."
    },
    {
        question = "Hoe verdien ik geld?",
        answer = "Er zijn verschillende manieren om geld te verdienen:\n1. Neem een legale baan bij het arbeidsbureau\n2. Voltooi missies en taken\n3. Handel in goederen bij verschillende winkels\n4. Start je eigen bedrijf\n5. Werk voor andere spelers"
    },
    {
        question = "Waar kan ik een auto kopen?",
        answer = "Je kunt voertuigen kopen bij de volgende locaties:\n- Premium Deluxe Motorsport (Centrum)\n- PDM Luxury (Vinewood)\n- Tweedehands Autohandel (Zuid)\nJe hebt een geldig rijbewijs nodig en genoeg geld voor het voertuig en de verzekering."
    },
    {
        question = "Hoe koop ik een huis?",
        answer = "Om een huis te kopen:\n1. Bezoek het makelaarskantoor in de stad\n2. Bekijk beschikbare woningen\n3. Zorg dat je genoeg geld hebt voor de aanbetaling\n4. Rond de aankoop af met een makelaar\n\nZorg dat je de betalingen op tijd doet om je eigendom te behouden!"
    },
    {
        question = "Wat zijn de server regels?",
        answer = "Bekijk de volledige regels op onze Discord. Belangrijkste punten:\n1. Geen RDM (Random Death Match)\n2. Blijf in karakter (geen FailRP)\n3. Respecteer andere spelers\n4. Volg staff instructies op\n5. Geen vals spelen of exploiten"
    }
}

-- Discord webhook voor bugrapporten
Config.DiscordWebhook = 'WEBHOOK_URL'

-- Gemini API Configuratie
Config.GeminiApiKey = 'YOUR_API_KEY'

Config.Debug = false -- Schakel debug prints in/uit
Config.DefaultResponse = "Het spijt me, maar ik heb moeite om het te begrijpen. Kunt u het alstublieft opnieuw proberen?"

-- Voeg deze nieuwe sectie toe voor server regels configuratie
Config.Rules = {
    Categories = {
        General = {
            title = "Algemene Regels",
            rules = {
                "Wees respectvol naar alle spelers en staff",
                "Geen intimidatie, discriminatie of haatzaaien",
                "Geen bugs misbruiken of vals spelen",
                "Volg staff instructies altijd op",
                "Alleen Nederlands in globale chat"
            }
        },
        Roleplay = {
            title = "Roleplay Regels",
            rules = {
                "Niet uit karakter vallen (FailRP)",
                "Geen willekeurig doden (RDM)",
                "Geen voertuig doodslag (VDM)",
                "Niet uitloggen tijdens gevechten",
                "Houd roleplay scenarios realistisch",
                "Geen powergaming of metagaming"
            }
        },
        Combat = {
            title = "Gevecht & PVP Regels",
            rules = {
                "Niet schieten vanuit voertuigen tenzij in RP scenario",
                "Niet kamperen bij ziekenhuizen of politiebureaus",
                "Vijandige bedoelingen aangeven voor aanval",
                "Niet uitloggen tijdens actieve situaties",
                "Respecteer New Life Rule na dood"
            }
        },
        Business = {
            title = "Zakelijke & Economische Regels",
            rules = {
                "Geen witwassen of exploiten",
                "Houd prijzen realistisch voor goederen/diensten",
                "Volg bedrijfszone voorschriften",
                "Meld economische exploits aan staff",
                "Geen kunstmatige marktmanipulatie"
            }
        },
        Communication = {
            title = "Communicatie Regels",
            rules = {
                "Houd OOC chat in juiste kanalen",
                "Geen reclame voor andere servers",
                "Geen spam of overmatig capslock",
                "Gebruik juiste radiokanalen",
                "Meld problemen via juiste kanalen"
            }
        }
    },
    
    Punishments = {
        levels = {
            warning = "Mondelinge/Schriftelijke Waarschuwing",
            kick = "Tijdelijke Kick",
            tempban = "Tijdelijke Ban (1-7 dagen)",
            permban = "Permanente Ban"
        },
        
        violations = {
            rdm = {
                name = "Willekeurig Doden (RDM)",
                first = "warning",
                second = "tempban",
                third = "permban"
            },
            failrp = {
                name = "Uit Karakter Vallen (FailRP)",
                first = "warning",
                second = "kick",
                third = "tempban"
            },
            cheating = {
                name = "Vals Spelen/Exploiten",
                first = "permban",
                appeal = false
            },
            harassment = {
                name = "Intimidatie/Discriminatie",
                first = "tempban",
                second = "permban",
                appeal = true
            }
        }
    },

    Appeals = {
        allowedFor = {
            "tempban",
            "permban"
        },
        waitTime = {
            tempban = 24, -- Uren voor appeal mogelijk is
            permban = 168 -- 7 dagen voor appeal mogelijk is
        },
        process = {
            "Vul appeal formulier in op Discord",
            "Wacht op staff beoordeling (24-48 uur)",
            "Neem deel aan appeal gesprek indien gevraagd",
            "Volg eventuele aanvullende eisen van staff op"
        }
    }
}