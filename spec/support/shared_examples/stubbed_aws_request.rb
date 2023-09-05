RSpec.shared_context 'with a stubbed AWS credentials request' do
  # Example raw XML document received by Aws::AssumeRoleWebIdentityCredentials
  # https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html
  let(:sts_xml) do
    <<-XML
      <AssumeRoleWithWebIdentityResponse xmlns="https://sts.amazonaws.com/doc/2011-06-15/">
      <AssumeRoleWithWebIdentityResult>
        <SubjectFromWebIdentityToken>amzn1.account.AF6RHO7KZU5XRVQJGXK6HB56KR2A</SubjectFromWebIdentityToken>
        <Audience>client.5498841531868486423.1548@the-role-session-name</Audience>
        <AssumedRoleUser>
          <Arn>role_arn</Arn>
          <AssumedRoleId>AROACLKWSDQRAOEXAMPLE:the-role-session-name</AssumedRoleId>
        </AssumedRoleUser>
        <Credentials>
          <SessionToken>AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE</SessionToken>
          <SecretAccessKey>wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY</SecretAccessKey>
          <Expiration>2014-10-24T23:00:23Z</Expiration>
          <AccessKeyId>ASgeIAIOSFODNN7EXAMPLE</AccessKeyId>
        </Credentials>
        <SourceIdentity>SourceIdentityValue</SourceIdentity>
        <Provider>www.amazon.com</Provider>
      </AssumeRoleWithWebIdentityResult>
      <ResponseMetadata>
        <RequestId>ad4156e9-bce1-11e2-82e6-6b6efEXAMPLE</RequestId>
      </ResponseMetadata>
      </AssumeRoleWithWebIdentityResponse>
    XML
  end

  before do
    stub_request(:post, 'https://sts.eu-west-2.amazonaws.com/')
      .with(
        body: {
          'Action' => 'AssumeRoleWithWebIdentity',
          'RoleArn' => 'role_arn',
          'RoleSessionName' => /.*/,
          'Version' => '2011-06-15',
          'WebIdentityToken' => /.*/
        },
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => '',
          'Content-Length' => '796',
          'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8',
          'User-Agent' => %r{aws-sdk-ruby3/.*}
        }
      )
      .to_return(status: 200, body: sts_xml, headers: {})
  end
end
