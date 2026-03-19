import { execSync } from 'child_process';

/**
 * GitHub Issue Planner Helper Script
 * GitHub CLI (gh) を使用して、Issue の取得・作成・更新を簡略化します。
 */

const args = process.argv.slice(2);
const command = args[0];

function checkGh() {
    try {
        execSync('gh --version');
    } catch (e) {
        try {
            execSync('"C:\\Program Files\\GitHub CLI\\gh.exe" --version');
            return true;
        } catch (e2) {
            console.error('Error: GitHub CLI (gh) が必要です。パスを通すか再インストールしてください。');
            process.exit(1);
        }
    }
}

function runGh(cmd) {
    try {
        return execSync(`gh ${cmd}`, { encoding: 'utf-8' });
    } catch (e) {
        return execSync(`"C:\\Program Files\\GitHub CLI\\gh.exe" ${cmd}`, { encoding: 'utf-8' });
    }
}

function listIssues() {
    try {
        const output = execSync('gh issue list --limit 10', { encoding: 'utf-8' });
        console.log(output);
    } catch (e) {
        console.error('Error: Issue 一覧の取得に失敗しました。');
    }
}

function createIssue(title, body) {
    try {
        const cmd = `gh issue create --title "${title.replace(/"/g, '\\"')}" --body "${body.replace(/"/g, '\\"')}"`;
        const output = execSync(cmd, { encoding: 'utf-8' });
        console.log(`Issue Created: ${output}`);
    } catch (e) {
        console.error('Error: Issue の作成に失敗しました。');
    }
}

function addComment(id, comment) {
    try {
        const cmd = `gh issue comment ${id} --body "${comment.replace(/"/g, '\\"')}"`;
        execSync(cmd);
        console.log(`Successfully commented on Issue ${id}`);
    } catch (e) {
        console.error('Error: コメントの追加に失敗しました。');
    }
}

async function main() {
    checkGh();

    switch (command) {
        case 'list':
            listIssues();
            break;
        case 'create':
            const titleArg = args.find(a => a.startsWith('--title='))?.split('=')[1];
            const bodyArg = args.find(a => a.startsWith('--body='))?.split('=')[1];
            if (!titleArg || !bodyArg) {
                console.error('Usage: node issue-tool.mjs create --title="Title" --body="Body"');
                return;
            }
            createIssue(titleArg, bodyArg);
            break;
        case 'comment':
            const id = args[1];
            const commentBody = args.slice(2).join(' ');
            if (!id || !commentBody) {
                console.error('Usage: node issue-tool.mjs comment <ID> <Comment>');
                return;
            }
            addComment(id, commentBody);
            break;
        default:
            console.log('Available commands: list, create, comment');
    }
}

main();
