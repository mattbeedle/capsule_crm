class CapsuleCRM::Contact

  def destroy
    CapsuleCRM::Connection.delete "/api/party/#{party_id}/contact/#{id}"
  end
end
