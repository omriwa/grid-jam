#!/bin/bash
# Grid-Jam repo push script
# Run from anywhere — copies files then pushes

REPO="omriwa/grid-jam"
BRANCH="main"

# Get latest SHA for index.html
SHA=$(curl -s https://api.github.com/repos/$REPO/contents/index.html \
  -H "Authorization: token $GITHUB_TOKEN" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sha',''))")
echo "Current SHA: $SHA"

push_file() {
  local path="$1"
  local local_file="$2"
  local msg="$3"
  local content=$(base64 -w 0 "$local_file")
  local current_sha=$(curl -s https://api.github.com/repos/$REPO/contents/$path \
    -H "Authorization: token $GITHUB_TOKEN" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sha',''))" 2>/dev/null)
  
  local payload="{\"message\": \"$msg\", \"content\": \"$content\", \"branch\": \"$BRANCH\""
  if [ -n "$current_sha" ]; then
    payload="$payload, \"sha\": \"$current_sha\""
  fi
  payload="$payload}"
  
  curl -s -X PUT "https://api.github.com/repos/$REPO/contents/$path" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload" | python3 -c "import sys,json; d=json.load(sys.stdin); print('✓' if 'content' in d else '✗', d.get('content',{}).get('name',''), d.get('message','ERROR')[:80])"
}

push_file "index.html" "index.html" "feat: 15-slide SEO slider with real images + product SVGs + attribution fix"
push_file "images/product-unit1.svg" "images/product-unit1.svg" "feat: Unit 1 omnidirectional 25W product diagram SVG"
push_file "images/product-unit2.svg" "images/product-unit2.svg" "feat: Unit 2 directional 25W product diagram SVG"
push_file "images/product-unit3.svg" "images/product-unit3.svg" "feat: Unit 3 high-power 500W product diagram SVG"
push_file "images/product-unit4.svg" "images/product-unit4.svg" "feat: Unit 4 ballistic 50km product diagram SVG"

echo "Done."
