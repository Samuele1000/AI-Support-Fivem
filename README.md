# The Sem: AI Ondersteuning

Een intelligent AI-aangedreven ondersteuningssysteem voor FiveM servers met gebruik van Google's Gemini API.

## Functies
- 🤖 AI-aangedreven antwoorden met Gemini Pro
- 🐛 Gestructureerd bugmeldsysteem
- 📍 Interactieve locatiemarkering
- 💬 Natuurlijke gespreksafhandeling
- 🌙 Donker/Licht thema ondersteuning
- 📋 Kopiëren-naar-klembord functionaliteit
- ⚡ Snelle actieknoppen
- 🔄 Contextbewuste antwoorden
- 📝 Markdown ondersteuning
- 💾 Chatgeschiedenis opslag

## Installatie
1. Download de resource
2. Voeg toe aan je resources map
3. Voeg toe aan `server.cfg`:
    ```plaintext
    ensure mt-support
    ```
4. Configureer je `config.lua`
5. Verkrijg een GRATIS Gemini API-sleutel van Google AI Studio

## Configuratie

### Essentiële Instellingen
```lua
Config.GeminiApiKey = 'YOUR_API_KEY' -- Required
Config.DiscordWebhook = 'YOUR_WEBHOOK' -- Optional, for bug reports
```

### Basisinstellingen
```lua
Config.Command = 'support'    -- Command to open support menu
Config.Key = 'F9'            -- Keybind to open menu
Config.Title = 'AI Support'  -- Window title
Config.EnableKeyMapping = true
```

### Serverinformatie
Configureer je serverdetails in `config.lua`:

- Servernaam, beschrijving en maximale slots
- Belangrijke locaties met coördinaten
- Serverregels en functies
- FAQ-items
- Beperkte informatie

## Gebruik

### Het Menu Openen
- Gebruik het geconfigureerde commando (`/support` standaard)
- Druk op de sneltoets (`F9` standaard)

### Functies

#### Bugrapportage
Het systeem begeleidt gebruikers door gestructureerde bugrapporten:

1. Categorie selectie
2. Bugbeschrijving
3. Stappen om te reproduceren
4. Aanvullende informatie
5. Bevestiging

#### Locatiemarkering
AI kan locaties op de kaart markeren wanneer gebruikers om aanwijzingen vragen:

- **Gebruiker**: "Waar is het ziekenhuis?"
- **AI**: "Het ziekenhuis bevindt zich in het centrum. Ik zal het voor je markeren!"

#### FAQ-systeem
Configureer veelgestelde vragen en antwoorden in `config.lua`:

```lua
Config.FAQ = {
    {
        question = "Hoe krijg ik een baan?",
        answer = "Bezoek het jobcenter op Legion Square..."
    }
}
```

### Aanpassing

#### Thema's
- Ondersteunt donkere en lichte thema's
- Gebruikersvoorkeur wordt opgeslagen
- Aanpasbare kleuren in `style.css`

#### Snelle Actieknoppen
Configureer snelle actieknoppen in `index.html`:

```html
<button class="quick-prompt-btn" data-prompt="report bug">
    <i class="fas fa-bug"></i>
    Bug Melden
</button>
```

### API-integratie
Het systeem gebruikt Google's Gemini API voor natuurlijke taalverwerking:

- Verzoeken zijn rate-limited
- Antwoorden zijn contextbewust
- Systeem prompts sturen AI-gedrag

## Afhankelijkheden
- FiveM server
- Google Gemini API-sleutel
- Discord webhook (optioneel)