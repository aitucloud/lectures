resource "random_pet" "animal" {
  for_each = toset([ "me", "mother", "aunt" ])
}
