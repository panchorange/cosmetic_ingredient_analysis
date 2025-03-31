import os
import io
import re
from google.cloud import vision
from google.oauth2 import service_account

def extract_ingredients_from_image(image_path, json_key_path):
    # 認証設定
    credentials = service_account.Credentials.from_service_account_file(json_key_path)
    client = vision.ImageAnnotatorClient(credentials=credentials)
    
    # 画像を読み込む
    with io.open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    # Vision APIリクエスト作成
    image = vision.Image(content=content)
    
    # テキスト検出実行（ドキュメントモードを使用）
    response = client.document_text_detection(image=image)
    
    if response.error.message:
        print(f'Error: {response.error.message}')
        return None
    
    # 検出されたテキスト取得
    if response.text_annotations:
        return response.text_annotations[0].description
    
    return None

def parse_ingredients(ingredients_text):
    # 成分リストは多くの場合「成分」や「全成分」の後に続く
    ingredients_section = re.search(r'(?:全成分|成分)[：:]\s*([\s\S]+)', ingredients_text)
    
    if ingredients_section:
        ingredients_raw = ingredients_section.group(1)
        
        # 一般的な区切り文字で分割（カンマ、改行など）
        ingredients = re.split(r'[,、\n]', ingredients_raw)
        
        # 空白除去と整形
        ingredients = [i.strip() for i in ingredients if i.strip()]
        
        return ingredients
    
    # 区切りキーワードが見つからない場合、テキスト全体を処理
    return [item.strip() for item in re.split(r'[,、\n]', ingredients_text) if item.strip()]

def save_to_text(ingredients, output_file):
    # 出力先のディレクトリが存在しない場合は作成
    output_dir = os.path.dirname(output_file)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # 成分をカンマ区切りでテキストファイルに出力
    with open(output_file, 'w', encoding='utf-8') as file:
        ingredients_text = ','.join(ingredients)
        file.write(ingredients_text)
    
    print(f"成分リストを出力しました: {output_file}")
    print(f"抽出された成分数: {len(ingredients)}個")

def process_cosmetic_image(image_path, json_key_path, output_text_file):
    # テキスト抽出
    extracted_text = extract_ingredients_from_image(image_path, json_key_path)
    
    if not extracted_text:
        print(f"テキストを抽出できませんでした: {image_path}")
        return
    
    # 成分解析
    ingredients = parse_ingredients(extracted_text)
    
    # テキストファイルに保存
    save_to_text(ingredients, output_text_file)
    
    # コンソールにも表示
    print("抽出された成分:")
    print(','.join(ingredients))

# 使用例
if __name__ == "__main__":
    # 現在のディレクトリを取得
    current_dir = os.getcwd()
    
    # output_txtフォルダとinput_imageフォルダのパスを設定
    json_key_path = os.path.join(current_dir, "innate-algebra-455208-k8-8abf98653233.json")
    output_txt_dir = os.path.join(current_dir, "output_txt")
    input_image_dir = os.path.join(current_dir, "input_image")
    
    # 出力ファイルと画像ファイルのパスを設定
    output_text_file = os.path.join(output_txt_dir, "cosmetics_ingredients.txt")
    image_path = os.path.join(input_image_dir, "image.png")
    
    # 処理実行
    process_cosmetic_image(
        image_path=image_path,
        json_key_path=json_key_path,
        output_text_file=output_text_file
    )
