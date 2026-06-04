# BuffRaidCheck

A World of Warcraft: Wrath of the Lich King (3.3.5a) addon to check if raid/group members have essential buffs.

## Features
- **Graphical User Interface:** Results are displayed in a scrollable Ace3 window.
- Checks for class-specific buffs based on group composition:
  - **Paladin:** Checks for Blessings (Kings, Might, Wisdom, Sanctuary) and Auras. Requires 1 blessing if 1 Paladin is in group, and at least 2 blessings if 2+ are present. Also checks for the presence of an Aura.
  - **Druid:** Mark of the Wild / Gift of the Wild.
  - **Priest:** Power Word: Fortitude / Prayer of Fortitude.
  - **Mage:** Arcane Intellect / Arcane Brilliance.
- Checks for **Flasks** and **Food** (Well Fed) buffs.
- **Standalone:** Includes embedded Ace3 libraries for easy installation.

## Usage
Type `/brc` or `/buffraidcheck` in the chat to open the results window.

## Requirements
- WoW WotLK 3.3.5a
