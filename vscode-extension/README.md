# Copilot Context Prepender

A lightweight VS Code extension that prepends your custom global instructions to every Copilot Chat request.

## Features

- **Custom Chat Participant**: Use `@contextual` in Copilot Chat
- **Flexible Configuration**: Point to a local file or public GitHub URL
- **Fresh Reads**: Loads your instructions on each request (always current)
- **Graceful Fallbacks**: Handles missing files/URLs without breaking chat

## Installation

1. Clone this extension locally
2. Run `npm install` in the `vscode-extension` directory
3. Press `F5` to launch the extension in a development host
4. Open Copilot Chat and type `@contextual`

## Configuration

Configure the context source in VS Code Settings (Ctrl+,):

```json
{
  "copilotContextPrepender.contextSource": "~/.copilot.md"
}
```

### Options

**Local File:**
```json
{
  "copilotContextPrepender.contextSource": "~/.copilot.md"
}
```

**GitHub URL (public, no auth required):**
```json
{
  "copilotContextPrepender.contextSource": "https://raw.githubusercontent.com/DerekRoberts/kilorules/main/rules/developer-profile.md"
}
```

**Absolute Path:**
```json
{
  "copilotContextPrepender.contextSource": "/Users/you/Documents/copilot-rules.md"
}
```

## Usage

1. Open Copilot Chat (Cmd+Shift+I or Ctrl+Shift+I)
2. Type `@contextual` to select the participant
3. Ask your question
4. Your custom instructions are automatically prepended

## How It Works

1. Extension reads `copilotContextPrepender.contextSource` setting
2. Detects if it's a URL or file path
3. Fetches/reads the content
4. Prepends it to your prompt before sending to Copilot
5. Streams Copilot's response back to chat

## Troubleshooting

**"Copilot model not available"**
- Ensure GitHub Copilot extension is installed and you have active Copilot Chat

**"Failed to fetch URL"**
- Check that the URL is public (no authentication required)
- Verify your network allows outbound HTTPS requests
- Check the URL is valid and the file exists

**"Failed to read ~/.copilot.md"**
- Ensure the file exists at the specified path
- Check file permissions

## Development

```bash
cd vscode-extension
npm install
npm run compile  # Build TypeScript
npm run watch    # Watch mode
```

Press `F5` to launch the extension host for testing.

## Publishing

To publish to the VS Code Marketplace:

```bash
npm install -g @vscode/vsce
vsce publish
```

You'll need to register a publisher and adjust the `publisher` field in `package.json`.
