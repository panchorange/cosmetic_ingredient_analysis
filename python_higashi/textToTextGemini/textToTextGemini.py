import os
import re
from google.cloud import aiplatform
from vertexai.preview.generative_models import GenerativeModel

# Google Cloud 認証の設定
# 環境変数で設定する場合は以下のコメントを外してください
# os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(os.getcwd(), "innate-algebra-455208-k8-8abf98653233.json")

def initialize_gemini():
    """Gemini 1.5 Flash モデルを初期化"""
    aiplatform.init(project="innate-algebra-455208-k8")
    model = GenerativeModel(model_name="gemini-1.5-flash")
    return model

def extract_cosmetics_ingredients(file_path):
    """化粧品成分テキストファイルを読み込み"""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    return content

def analyze_ingredients(model, content):
    """Gemini APIを使用して化粧品成分を分析"""
    prompt = f"""
    以下の化粧品成分リストから、各化粧品の成分を分析してください。
    
    {content}
    
    各化粧品について、以下の形式で出力してください：
    化粧品名,説明
    各化粧品の成分について詳細に分析し、その効果と特徴を説明してください。
    """
    
    response = model.generate_content(prompt)
    return response.text

def generate_summary(model, analysis_result):
    """分析結果を基に総合評価を生成"""
    prompt = f"""
    以下の化粧品成分分析結果に基づいて、200-300文字程度の総合評価を作成してください：
    
    {analysis_result}
    
    総合評価では、全体的な傾向、主要な効果、注目すべき成分などに触れてください。
    """
    
    response = model.generate_content(prompt)
    return response.text

def save_results(analysis_result, summary, output_file):
    """分析結果と総合評価をファイルに保存"""
    with open(output_file, 'w', encoding='utf-8') as file:
        file.write("成分\n")
        file.write(analysis_result)
        file.write("\n\n総合評価\n")
        file.write(summary)
    print(f"結果を {output_file} に保存しました。")

def main():
    # 入力ファイルと出力ファイルのパス
    input_file = os.path.join(os.getcwd(), "input_txt", "cosmetics_ingredients.txt")
    output_file = os.path.join(os.getcwd(), "output_txt", "cosmetics_ingredients_result.txt")
    
    # output_txtディレクトリが存在しない場合は作成
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    try:
        # Gemini モデルの初期化
        model = initialize_gemini()
        
        # 化粧品成分ファイルの読み込み
        content = extract_cosmetics_ingredients(input_file)
        
        # 成分分析の実行
        analysis_result = analyze_ingredients(model, content)
        
        # 総合評価の生成
        summary = generate_summary(model, analysis_result)
        
        # 結果の保存
        save_results(analysis_result, summary, output_file)
        
        print("化粧品成分の分析が完了しました。")
        
    except Exception as e:
        print(f"エラーが発生しました: {str(e)}")

if __name__ == "__main__":
    main()