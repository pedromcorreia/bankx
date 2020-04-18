defmodule Bankx.Encryption.AES do
  # Use AES 256 Bit Keys for Encryption.
  @aad "AES256GCM"

  def encrypt(plaintext) do
    # create random Initialisation Vector
    iv = :crypto.strong_rand_bytes(16)
    # get the *latest* key in the list of encryption keys
    {ciphertext, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {@aad, to_string(plaintext), 16})
    # "return" iv with the cipher tag & ciphertext
    iv <> tag <> ciphertext
  end

  def decrypt(ciphertext) do
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(:aes_gcm, key(), iv, {@aad, ciphertext, tag})
  end

  # this is a "dummy function" we will update it in step 3.3
  defp key do
    Base.decode64!("AxZMGDgP0bt8MXcn7issnWMsQPxgutYHME8DKA7V7uI=")
  end
end
