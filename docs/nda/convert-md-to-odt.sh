#!/bin/bash

# Script: convert-md-to-odt.sh
# Beschreibung: Konvertiert alle .md-Dateien im aktuellen Ordner zu .odt-Format
# Verwendung: ./convert-md-to-odt.sh

echo "=========================================="
echo "Markdown zu ODT Konverter"
echo "=========================================="
echo ""

# Prüfe ob pandoc installiert ist
if ! command -v pandoc &> /dev/null; then
    echo "FEHLER: pandoc ist nicht installiert!"
    echo "Installation: sudo apt-get install pandoc"
    exit 1
fi

# Zähler für konvertierte Dateien
count=0
errors=0

# Finde alle .md-Dateien im aktuellen Verzeichnis
while IFS= read -r -d '' md_file; do
    # Erstelle den ODT-Dateinamen (ersetze .md mit .odt)
    odt_file="${md_file%.md}.odt"

    echo "Konvertiere: $(basename "$md_file")"

    # Führe die Konvertierung durch
    if pandoc "$md_file" -o "$odt_file"; then
        echo "  ✓ Erfolgreich: $(basename "$odt_file")"
        ((count++))
    else
        echo "  ✗ Fehler bei: $(basename "$md_file")"
        ((errors++))
    fi
    echo ""

done < <(find . -maxdepth 1 -name "*.md" -type f -print0)

# Zusammenfassung
echo "=========================================="
echo "Zusammenfassung:"
echo "  Erfolgreich konvertiert: $count Datei(en)"
if [ $errors -gt 0 ]; then
    echo "  Fehler: $errors Datei(en)"
fi
echo "=========================================="

# Exit-Code setzen
if [ $errors -gt 0 ]; then
    exit 1
else
    exit 0
fi
