# 🧼 Solidity Linting Guide (Solhint + GitHub Actions)

This repository uses `solhint` for Solidity linting and style enforcement.  
GitHub Actions automatically runs the linter on every push and pull request.


## ✅ Step 1: Install Solhint Locally

Run these commands in your project root:

```bash
npm init -y
npm install --save-dev solhint
npx solhint --init
```
This creates:

package.json with Solhint listed

.solhint.json configuration file

⚙️ Step 2: Configure Linter Rules
Edit .solhint.json in the repo root:

```json
{
  "extends": "solhint:recommended",
  "rules": {
    "compiler-version": ["error", "^0.8.19"],
    "func-visibility": ["warn", { "ignoreConstructors": true }],
    "max-line-length": ["warn", 120]
  }
}
```
These rules can be customized. See: https://protofire.github.io/solhint/

🧾 Step 3: Add GitHub Actions Workflow
Create this file at .github/workflows/solhint.yml:

```yaml
name: Solidity Linter (Solhint)

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install

      - name: Run Solhint
        run: npx solhint 'contracts/**/*.sol'
```
🧪 Optional: Ignore Files from Linting
Create .solhintignore:

```bash
test/
mocks/
```
📣 Result
Every push and pull request will automatically run the linter.
PRs will show lint warnings and errors in the GitHub Actions tab.

Built for NeuralNode by Professor Codephreak
