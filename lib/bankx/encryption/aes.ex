defmodule Bankx.Encryption.AES do
  @moduledoc false
  @aad "AES256GCM"

  def encrypt(plaintext) do
    iv = :crypto.strong_rand_bytes(16)

    {ciphertext, tag} =
      :crypto.block_encrypt(
        :aes_gcm,
        key(),
        iv,
        {@aad, to_string(plaintext), 16}
      )

    iv <> tag <> ciphertext
  end

  def decrypt(ciphertext) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(:aes_gcm, key(), iv, {@aad, ciphertext, tag})
  end

  defp key do
    Base.decode64!("AxZMGDgP0bt8MXcn7issnWMsQPxgutYHME8DKA7V7uI=")
  end
end
