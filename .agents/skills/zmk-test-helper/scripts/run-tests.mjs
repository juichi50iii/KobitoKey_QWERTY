import { execSync } from 'child_process';

/**
 * ZMK Test Helper Script
 * west test を実行し、結果をパースして失敗したケースを抽出します。
 */

function runWestTest() {
    try {
        console.log('Running west test...');
        // ログをキャプチャするために stdout を取得
        const output = execSync('west test', { encoding: 'utf-8', stdio: 'pipe' });
        console.log(output);
        console.log('All tests passed!');
    } catch (e) {
        console.error('Test Failed.');
        if (e.stdout) {
            parseTestResults(e.stdout);
        } else {
            console.error(e.message);
        }
    }
}

function parseTestResults(output) {
    const lines = output.split('\n');
    const failedCases = lines.filter(line => line.includes('FAILED') || line.includes('ERROR'));
    
    if (failedCases.length > 0) {
        console.log('\n--- Failed Test Cases ---');
        failedCases.forEach(c => console.log(c.trim()));
        console.log('-------------------------');
    } else {
        console.log('エラーの詳細は出力ログの全文を確認してください。');
    }
}

runWestTest();
