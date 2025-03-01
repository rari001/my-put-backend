class UploadsController < ApplicationController
  def create
    uploaded_file = params[:images]

    if uploaded_file.present?
      # 画像を一時的に保存（Postのimageに添付）
      post = Post.new
      post.image.attach(uploaded_file)

      if post.save
        # アップロードした画像のURLを返す
        render json: { url: rails_blob_path(post.image, only_path: true) }, status: :created
      else
        render json: { error: "画像のアップロードに失敗しました。" }, status: :unprocessable_entity
      end
    else
      render json: { error: "画像が送信されませんでした。" }, status: :unprocessable_entity
    end
  end
end
