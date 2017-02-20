# Delete a discription link by providing a substring of the target identifier.
#
# @example
#   Given the identifier mc_foo, delete it from the description:
#     !ddl foo
class DeleteLinkAction < WithArgumentsAction
  def run(msg)
    id = DescriptionLinkStore.find_all_including_key(msg[0], true).first
    DescriptionLinkStore.delete(id.first)
  end
end
