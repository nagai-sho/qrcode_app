class QrcodesController < ApplicationController
  require 'rqrcode'
  require 'chunky_png'

  def new
    @qrcode = Qrcode.new
  end

  def create
    @qrcode = Qrcode.new(qrcode_params)
    if @qrcode.save
      generate_qr_code(@qrcode)
      # url_for(@qrcode): @qrcodeオブジェクトに対応するURLを生成するRailsのヘルパーメソッド
      render json: { success: true, qr_code_url: url_for(@qrcode) }
    else
      render json: { success: false, errors: @qrcode.errors.full_messages }
    end
  end

  def show
    @qrcode = Qrcode.find_by(token: params[:token])
    if @qrcode && @qrcode.expires_at > Time.current
      send_file @qrcode.file_name, type: 'image/png', disposition: 'inline'
    else
      render plain: 'QRコードが見つからないか、有効期限が切れています', status: :not_found
    end
  end

  private
  def qrcode_params
    params.require(:qrcode).permit(:url)
  end

  def generate_qr_code(qr_code)
    qrcode = RQRCode::QRCode.new(encrypt_url(qr_code.url))
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 300
    )
    file_name = "qr_#{qr_code.token}.png"
    file_path = Rails.root.join('public', 'qr_codes', file_name)
    IO.binwrite(file_path, png.to_s)
    qr_code.update(file_name: file_path.to_s)
  end

  # 与えられたURLを暗号化し、Base64 URLセーフエンコーディングを行う機能
  def encrypt_url(url)
    # 暗号化アルゴリズム（AES-256-CBC）を使用するOpenSSL::Cipherオブジェクトを作成
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    # 暗号化モードに設定
    cipher.encrypt
    # 環境変数から暗号化キーを取得し、cipherオブジェクトに設定
    cipher.key = ENV['ENCRYPTION_KEY']
    # cipher.updateメソッドでURLを暗号化し、cipher.finalで暗号化処理を完了させる。
    encrypted = cipher.update(url) + cipher.final
    # 暗号化されたデータをBase64 URLセーフエンコーディングする。
    Base64.urlsafe_encode64(encrypted)
  end
end
