import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import https from 'https';
import http from 'http';

export function activate(context: vscode.ExtensionContext) {
  const handler: vscode.ChatRequestHandler = async (
    request: vscode.ChatRequest,
    chatContext: vscode.ChatContext,
    stream: vscode.ChatResponseStream,
    token: vscode.CancellationToken
  ) => {
    try {
      // Get configuration
      const config = vscode.workspace.getConfiguration('copilotContextPrepender');
      let contextSource = config.get<string>('contextSource', '~/.copilot.md');

      // Expand ~ to home directory
      if (contextSource.startsWith('~')) {
        const homeDir = process.env.HOME || process.env.USERPROFILE || '';
        contextSource = contextSource.replace('~', homeDir);
      }

      let customContext = '';

      // Detect if it's a URL or file path
      if (contextSource.startsWith('http://') || contextSource.startsWith('https://')) {
        // Fetch from URL
        customContext = await fetchFromUrl(contextSource);
      } else {
        // Read from local file
        customContext = await readLocalFile(contextSource);
      }

      // Get Copilot model
      const [model] = await vscode.lm.selectChatModels({
        vendor: 'copilot',
        family: 'gpt-4o'
      });

      if (!model) {
        stream.markdown('⚠️ Copilot model not available.');
        return;
      }

      // Prepare messages with custom context prepended
      const messages: vscode.LanguageModelChatMessage[] = [
        vscode.LanguageModelChatMessage.User(
          `You have the following custom instructions:\n\n${customContext}\n\n---\n\nUser request:`
        ),
        vscode.LanguageModelChatMessage.User(request.prompt)
      ];

      // Send to model and stream response
      const response = await model.sendRequest(messages, {}, token);
      for await (const chunk of response.text) {
        stream.markdown(chunk);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      stream.markdown(`❌ Error: ${message}`);
    }
  };

  // Create and register the chat participant
  const participant = vscode.chat.createChatParticipant(
    'copilot-context.contextual',
    handler
  );

  participant.iconPath = new vscode.ThemeIcon('sparkles');

  context.subscriptions.push(participant);
}

async function fetchFromUrl(url: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;

    protocol
      .get(url, { timeout: 5000 }, (res) => {
        if (res.statusCode !== 200) {
          reject(new Error(`HTTP ${res.statusCode}: Failed to fetch ${url}`));
          return;
        }

        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          resolve(data);
        });
      })
      .on('error', (err) => {
        reject(new Error(`Failed to fetch ${url}: ${err.message}`));
      });
  });
}

async function readLocalFile(filePath: string): Promise<string> {
  try {
    return await fs.promises.readFile(filePath, 'utf-8');
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(`Failed to read ${filePath}: ${message}`);
  }
}

export function deactivate() {}
