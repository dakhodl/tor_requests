require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Http" do

  describe "get" do

    context "with invalid parameters" do
      it "does not work" do
        expect { Tor::HTTP.get("google.com") }.to raise_error
      end
    end

    context "with URI parameter" do
      ["http", "https"].each do |protocol|
        it "follows the #{protocol} redirects" do
          stub = stub_request(:get, "#{protocol}://google.com/").
            with(
              headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
              }).
            to_return(status: 200, body: "", headers: {})
          res = Tor::HTTP.get(URI("#{protocol}://google.com/"))
          res.code.should eq("200")
          expect(stub).to have_been_requested
        end

        context "with custom redirects limit" do
          it "raises TooManyRedirects error after 1 retry" do
            stub1 = stub_request(:get, "#{protocol}://bit.ly/1ngrqeH").
              with(
                headers: {
                  'Accept'=>'*/*',
                  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'User-Agent'=>'Ruby'
                }).
              to_return(status: 301, body: "", headers: {"Location": 'http://google.com'})
            stub2 = stub_request(:get, "#{protocol}://bit.ly/").
              with(
                headers: {
                  'Accept'=>'*/*',
                  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'User-Agent'=>'Ruby'
                }).
              to_return(status: 301, body: "", headers: {"Location": 'http://google.com'})
            expect { Tor::HTTP.get(URI("#{protocol}://bit.ly/1ngrqeH"), nil, nil, 1) }.to raise_error("Tor::HTTP::TooManyRedirects")
            expect(stub1).to have_been_requested
            expect(stub2).to have_been_requested
          end
        end

      end
    end

    context "with host, path and port parameters" do
      it "works" do
        stub = stub_request(:get, "http://google.com").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})
        res = Tor::HTTP.get("google.com", "/", 80)
        res.code.should eq("200")
        expect(stub).to have_been_requested
      end
    end

  end

  describe "post" do

    context "with invalid parameters" do
      it "does not work" do
        expect { Tor::HTTP.post("google.com") }.to raise_error
      end
    end

    context "with URI parameter" do
      ["http", "https"].each do |protocol|
        it "works with #{protocol}" do
          stub = stub_request(:post, "#{protocol}://posttestserver.com/post.php?dir=example").
          with(
            body: {"q"=>"query", "var"=>"variable"}.to_json,
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: "", headers: {})
          res = Tor::HTTP.post(URI("#{protocol}://posttestserver.com/post.php?dir=example"), {"q" => "query", "var" => "variable"})
          res.code.should eq("200")
          expect(stub).to have_been_requested
        end
      end
    end

    context "with host, path and port parameters" do
      it "works" do
        stub = stub_request(:post, "http://posttestserver.com/post.php?dir=example").
         with(
           body: {"q"=>"query", "var"=>"variable"}.to_json,
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})
        res = Tor::HTTP.post('posttestserver.com', {"q" => "query", "var" => "variable"}, '/post.php?dir=example', 80)
        res.code.should eq("200")
        expect(stub).to have_been_requested
      end

    end

  end

end
