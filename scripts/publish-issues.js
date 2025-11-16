#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const yaml = require('js-yaml');

const ISSUES_DIR = path.join(__dirname, '..', '.github', 'issues');

/**
 * Citește și validează un fișier YAML pentru issue
 */
function parseIssueFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const issue = yaml.load(content);

    if (!issue.title) {
      throw new Error(`Fișierul ${filePath} nu are 'title'`);
    }

    return {
      title: issue.title,
      body: issue.body || '',
      labels: issue.labels || [],
      assignees: issue.assignees || []
    };
  } catch (error) {
    console.error(`❌ Eroare la parsarea ${filePath}:`, error.message);
    return null;
  }
}

/**
 * Creează un label dacă nu există
 */
function ensureLabelExists(labelName, color = '0366d6', description = '') {
  try {
    // Verifică dacă label-ul există
    execSync(`gh label list | grep -q "^${labelName}"`, { stdio: 'ignore' });
    return true; // Label există deja
  } catch {
    // Label-ul nu există, încearcă să-l creezi
    try {
      console.log(`🏷️  Creare label: ${labelName}`);
      execSync(`gh label create "${labelName}" --description "${description}" --color "${color}"`, { stdio: 'ignore' });
      return true;
    } catch (error) {
      console.warn(`⚠️  Nu pot crea label-ul "${labelName}":`, error.message);
      return false;
    }
  }
}

/**
 * Creează un issue folosind GitHub CLI
 */
function createIssue(issue) {
  try {
    console.log(`📝 Creare issue: "${issue.title}"`);

    // Asigură că toate labels există înainte de creare
    const validLabels = [];
    for (const label of issue.labels) {
      if (ensureLabelExists(label)) {
        validLabels.push(label);
      }
    }

    let command = `gh issue create --title "${issue.title.replace(/"/g, '\\"')}"`;

    if (issue.body) {
      // Scrie body într-un fișier temporar pentru a evita probleme cu quoting-ul
      const tempFile = `/tmp/issue-body-${Date.now()}.md`;
      fs.writeFileSync(tempFile, issue.body);
      command += ` --body-file "${tempFile}"`;
    }

    if (validLabels.length > 0) {
      command += ` --label "${validLabels.join(',')}"`;
    }

    if (issue.assignees.length > 0) {
      command += ` --assignee "${issue.assignees.join(',')}"`;
    }

    console.log(`🔧 Executare: ${command}`);
    const result = execSync(command, { encoding: 'utf8' });

    console.log(`✅ Issue creat: ${result.trim()}`);

    // Curăță fișierul temporar dacă există
    if (issue.body) {
      const tempFile = result.match(/--body-file "([^"]+)"/)?.[1];
      if (tempFile && fs.existsSync(tempFile)) {
        fs.unlinkSync(tempFile);
      }
    }

    return result.trim();
  } catch (error) {
    console.error(`❌ Eroare la crearea issue-ului "${issue.title}":`, error.message);
    return null;
  }
}

/**
 * Procesează toate fișierele YAML din folderul issues
 */
function processIssues() {
  if (!fs.existsSync(ISSUES_DIR)) {
    console.log('❌ Folderul .github/issues nu există');
    return;
  }

  const files = fs.readdirSync(ISSUES_DIR)
    .filter(file => file.endsWith('.yml') || file.endsWith('.yaml'))
    .filter(file => file !== 'README.md'); // Exclude README

  if (files.length === 0) {
    console.log('ℹ️  Nu există fișiere YAML în folderul .github/issues');
    return;
  }

  console.log(`🔍 Găsite ${files.length} fișiere de issues:`);
  files.forEach(file => console.log(`   - ${file}`));

  let successCount = 0;
  let errorCount = 0;

  for (const file of files) {
    const filePath = path.join(ISSUES_DIR, file);
    console.log(`\n📄 Procesare: ${file}`);

    const issue = parseIssueFile(filePath);
    if (!issue) {
      errorCount++;
      continue;
    }

    const issueUrl = createIssue(issue);
    if (issueUrl) {
      successCount++;
      // Opțional: șterge fișierul după creare reușită
      // fs.unlinkSync(filePath);
      // console.log(`🗑️  Fișier șters: ${file}`);
    } else {
      errorCount++;
    }
  }

  console.log(`\n📊 Rezumat: ${successCount} reușite, ${errorCount} eșecuri`);

  if (successCount > 0) {
    console.log('🎉 Issues publicate cu succes pe GitHub!');
  }
}

// Verifică dacă GitHub CLI este instalat și autentificat
function checkGitHubCLI() {
  try {
    execSync('gh --version', { stdio: 'ignore' });
    console.log('✅ GitHub CLI găsit');

    // Verifică autentificarea
    try {
      execSync('gh auth status', { stdio: 'ignore' });
      console.log('✅ GitHub CLI autentificat');
    } catch {
      console.log('⚠️  GitHub CLI nu este autentificat. Rulează: gh auth login');
      process.exit(1);
    }
  } catch {
    console.log('❌ GitHub CLI nu este instalat. Instalează-l de la: https://cli.github.com/');
    process.exit(1);
  }
}

// Funcția principală
function main() {
  console.log('🚀 Începere publicare issues locale...\n');

  checkGitHubCLI();
  processIssues();

  console.log('\n✨ Finalizat!');
}

// Rulează scriptul
if (require.main === module) {
  main();
}

module.exports = { parseIssueFile, createIssue, processIssues };
