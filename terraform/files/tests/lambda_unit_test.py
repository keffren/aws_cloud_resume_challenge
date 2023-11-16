import unittest
import boto3

class TestGet(unittest.TestCase):

    dynamodb = boto3.resource('dynamodb', region_name='eu-west-1')
    table = dynamodb.Table('resume-challenge-counter')
    
    def test_table(self):
        """
        Check the dynamodb table exists
        """
        self.assertEqual(self.table.table_name, 'resume-challenge-counter')

    def test_table_empty(self):
        """
        Check whether dynamodb table is empty
        """
        items_number = self.table.item_count

        if items_number == 0:
            is_empty = True
        else:
            is_empty = False

        self.assertFalse(is_empty)

    def test_visitorsNumber_value(self):
        """
        Check the count value is valid
        """
        item = self.table.get_item(Key={"CounterId": "mainCounter"})

        #Get the counter value
        counter_value = int(item["Item"]["visitorsNumber"])

        if 0 <= counter_value:
            is_valid = True
        else:
            is_valid = False
        
        self.assertTrue(is_valid)

if __name__ == '__main__':
    unittest.main()