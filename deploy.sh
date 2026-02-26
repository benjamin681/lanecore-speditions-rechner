#!/bin/bash
# ================================================
# LaneCore Speditions-Rechner - Deploy to GitHub Pages
# ================================================
# Dieses Script macht alles automatisch:
# 1. GitHub Login (falls noetig)
# 2. Repo erstellen
# 3. Pushen
# 4. GitHub Pages aktivieren
# ================================================

GH="$HOME/.local/bin/gh"
REPO_NAME="lanecore-speditions-rechner"

echo ""
echo "========================================"
echo "  LaneCore Rechner - GitHub Pages Deploy"
echo "========================================"
echo ""

# 1. Check if gh is authenticated
if ! $GH auth status &>/dev/null; then
    echo "Schritt 1: GitHub Login..."
    echo ""
    $GH auth login --web -p https
    if [ $? -ne 0 ]; then
        echo "Login fehlgeschlagen. Bitte versuche es erneut."
        exit 1
    fi
    echo ""
    echo "Login erfolgreich!"
fi

echo ""
echo "Schritt 2: Repository erstellen..."

# 2. Create repo (public for GitHub Pages free)
$GH repo create "$REPO_NAME" --public --description "KI-Einsparpotential-Rechner fuer Speditionen - LaneCore AI" 2>/dev/null

# Get username
GH_USER=$($GH api user --jq '.login')
echo "GitHub User: $GH_USER"

# 3. Set remote and push
echo ""
echo "Schritt 3: Code pushen..."
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
git branch -M main
git push -u origin main

# 4. Enable GitHub Pages
echo ""
echo "Schritt 4: GitHub Pages aktivieren..."
$GH api -X POST "repos/$GH_USER/$REPO_NAME/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/" 2>/dev/null

# Wait a moment for Pages to build
echo ""
echo "Warte 10 Sekunden auf Build..."
sleep 10

# 5. Get URL
PAGES_URL="https://$GH_USER.github.io/$REPO_NAME/"

echo ""
echo "========================================"
echo "  FERTIG!"
echo "========================================"
echo ""
echo "  Deine App ist live unter:"
echo ""
echo "  $PAGES_URL"
echo ""
echo "  (Kann 1-2 Minuten dauern bis die"
echo "   Seite zum ersten Mal geladen wird)"
echo ""
echo "========================================"
echo ""

# Try to open in browser
open "$PAGES_URL" 2>/dev/null || xdg-open "$PAGES_URL" 2>/dev/null
