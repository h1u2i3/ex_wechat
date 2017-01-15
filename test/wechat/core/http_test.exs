defmodule Wechat.HttpTest do
  use ExUnit.Case, async: true

  alias Wechat.Http
  alias Wechat.TestCase

  # use httparrot to check with http request
  @url "http://httpbin.org"

  describe "Right request" do
    test "get should get right things" do
      options = [url: "#{@url}/get", params: [foo: "bar"]]
      response = Http.get(options, &parse_http_test_result/1)

      assert response.args == %{foo: "bar"}
    end

    test "post should post with right things" do
      options = [url: "#{@url}/post", body: "body", params: [foo: "bar"]]
      response = Http.post(options, &parse_http_test_result/1)

      assert response.args == %{foo: "bar"}
      assert response.data == "body"
    end
  end

  describe "Error request" do
    test "deal with get error response" do
      response = do_error_request(:get)
      assert response == %{error: "test"}
    end

    test "deal with post error response" do
      response = do_error_request(:post)
      assert response == %{error: "test"}
    end
  end

  describe "Callbacks" do
    test "parse response get should do the right when get right response" do
      options = [url: "#{@url}/get", params: [foo: "bar"]]
      callback = &Http.parse_response(&1, :one, :two, :three, :four)
      response = Http.get(options, callback)

      assert response.args == %{foo: "bar"}
    end

    test "parse response get should do the right when get wrong response" do
      TestCase.http_fake({:error, %{reason: "test"}})
      options = [url: @url, body: "body", params: []]
      callback = &Http.parse_response(&1, :one, :two, :three, :four)

      assert Http.get(options, callback) == %{error: "test"}
    end
  end

  defp parse_http_test_result(result) do
    case result do
      {:ok, response} ->
        Poison.decode!(response.body, keys: :atoms)
      {:error, error} ->
        %{error: error.reason}
    end
  end

  defp do_error_request(verb) do
    TestCase.http_fake({:error, %{reason: "test"}})
    options = [url: @url, body: "body", params: []]
    apply(Http, verb, [options, &parse_http_test_result/1])
  end
end
