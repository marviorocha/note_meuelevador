require "test_helper"

class Api::V1::NotesTest < ActionDispatch::IntegrationTest
  setup do
    @author = Author.create!(name: "Test Author")
    @category = Category.create!(name: "Test Category")
    @subcategory = Subcategory.create!(name: "Test Subcategory", category: @category)
    @note = Note.create!(
      author: @author,
      subcategory: @subcategory,
      content: "Initial content",
      status: :revisar
    )
  end

  test "should get index" do
    get api_v1_notes_url, as: :json
    assert_response :success
  end

  test "should create note with names" do
    assert_difference("Note.count") do
      post api_v1_notes_url, params: {
        note: {
          author_name: "New Author",
          category_name: "New Category",
          subcategory_name: "New Subcategory",
          content: "New content",
          status: "ok"
        },
        tags: ["tag1", "tag2"]
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New content", json_response["content"]
    assert_equal "ok", json_response["status"]
  end

  test "should update note" do
    patch api_v1_note_url(@note), params: {
      note: { content: "Updated content" }
    }, as: :json
    assert_response :success
    @note.reload
    assert_equal "Updated content", @note.content
  end

  test "should destroy note" do
    assert_difference("Note.count", -1) do
      delete api_v1_note_url(@note), as: :json
    end

    assert_response :no_content
  end
end
