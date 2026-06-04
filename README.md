# BuffRaidCheck

A World of Warcraft: Wrath of the Lich King (3.3.5a) addon to check if raid/group members have essential buffs.

## Features
- **Detailed Scan Window:** View specific missing buffs for every raid member.
- **Whisper Feature:** Click the **"W"** button next to a player to whisper them a list of their missing buffs.
- **Interface Options:** Access settings via **Escape > Interface > Addons > BuffRaidCheck**.
  - Customize the whisper message prefix.
  - Toggle Paladin Aura checking.
- **Class Logic:**
  - **Paladin:** Checks for Blessings (1 if 1 Paladin, 2 if 2+) and Auras.
  - **Druid:** Mark/Gift of the Wild.
  - **Priest:** Fortitude.
  - **Mage:** Intellect.
- **Consumables:** Checks for Flasks and Food.

## Usage
- `/brc` or `/buffraidcheck`: Open the detailed scan results window.

## Requirements
- WoW WotLK 3.3.5a
