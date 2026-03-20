import { execSync } from 'child_process';

/**
 * ZMK Build Checker Helper Script
 * GitHub CLI (gh) を使用して、最新の失敗したワークフローランのログを取得し、
 * エラー箇所を抽出して要約します。
 */

function checkGhInstalled() {
    try {
        execSync('gh --version');
    } catch (e) {
        // PATH にない場合、標準的なインストール先を確認
        try {
            execSync('"C:\\Program Files\\GitHub CLI\\gh.exe" --version');
            console.log('Note: GitHub CLI was found at "C:\\Program Files\\GitHub CLI\\gh.exe"');
            return true;
        } catch (e2) {
            console.error('Error: GitHub CLI (gh) がインストールされていないか、パスが通っていません。');
            process.exit(1);
        }
    }
}

function runGh(cmd) {
    try {
        return execSync(`gh ${cmd}`, { encoding: 'utf-8' });
    } catch (e) {
        // フォールバック
        return execSync(`"C:\\Program Files\\GitHub CLI\\gh.exe" ${cmd}`, { encoding: 'utf-8' });
    }
}

function getLatestFailedRun() {
    try {
        const output = execSync('gh run list --status failure --limit 1 --json databaseId,displayTitle,createdAt', { encoding: 'utf-8' });
        const runs = JSON.parse(output);
        return runs.length > 0 ? runs[0] : null;
    } catch (e) {
        console.error('Error: ワークフロー実行履歴の取得に失敗しました。');
        return null;
    }
}

function getRunLog(runId) {
    try {
        // 全ログを取得すると巨大な場合があるため、失敗したジョブのログのみを取得
        return execSync(`gh run view ${runId} --log-failed`, { encoding: 'utf-8' });
    } catch (e) {
        console.error('Error: ログの取得に失敗しました。');
        return '';
    }
}

function summarizeLog(log) {
    const lines = log.split('\n');
    const errorLines = lines.filter(line => 
        line.includes('error:') || 
        line.includes('FATAL ERROR') || 
        line.includes('failed with exit code')
    );

    if (errorLines.length === 0) {
        return '明確なエラー行は見つかりませんでした。ログ全体を確認してください。';
    }

    return errorLines.join('\n');
}

async function main() {
    console.log('--- ZMK Build Log Checker ---');
    checkGhInstalled();

    const latestRun = getLatestFailedRun();
    if (!latestRun) {
        console.log('直近で失敗したワークフローは見つかりませんでした。');
        return;
    }

    console.log(`Analyzing Run: ${latestRun.displayTitle} (${latestRun.createdAt})`);
    console.log(`ID: ${latestRun.databaseId}`);
    console.log('---------------------------');

    const log = getRunLog(latestRun.databaseId);
    const summary = summarizeLog(log);

    console.log('Potential Error Causes:');
    console.log(summary);
    console.log('---------------------------');
}

main();
