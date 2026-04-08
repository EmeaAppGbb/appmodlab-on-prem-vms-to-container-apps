// Seed script to populate MongoDB with sample data
const mongoose = require('mongoose');

const MONGODB_URI = 'mongodb://localhost:27017/pawscare';

const patientData = [
    { name: 'Max', species: 'Dog', breed: 'Golden Retriever', dateOfBirth: new Date('2018-05-15'), ownerId: '1', ownerName: 'John Smith', microchipNumber: 'MC001234567', notes: 'Friendly, loves treats' },
    { name: 'Luna', species: 'Cat', breed: 'Siamese', dateOfBirth: new Date('2019-08-22'), ownerId: '2', ownerName: 'Sarah Johnson', microchipNumber: 'MC001234568', notes: 'Shy with strangers' },
    { name: 'Charlie', species: 'Dog', breed: 'Labrador', dateOfBirth: new Date('2017-03-10'), ownerId: '3', ownerName: 'Michael Brown', microchipNumber: 'MC001234569', notes: 'Very energetic' },
    { name: 'Bella', species: 'Cat', breed: 'Persian', dateOfBirth: new Date('2020-01-05'), ownerId: '4', ownerName: 'Emily Davis', microchipNumber: 'MC001234570', notes: 'Requires regular grooming' },
    { name: 'Rocky', species: 'Dog', breed: 'German Shepherd', dateOfBirth: new Date('2016-11-30'), ownerId: '5', ownerName: 'David Wilson', microchipNumber: 'MC001234571', notes: 'Police dog training' },
    { name: 'Whiskers', species: 'Cat', breed: 'Maine Coon', dateOfBirth: new Date('2019-06-18'), ownerId: '6', ownerName: 'Jennifer Martinez', microchipNumber: 'MC001234572', notes: 'Large breed, gentle' },
    { name: 'Buddy', species: 'Dog', breed: 'Beagle', dateOfBirth: new Date('2018-09-25'), ownerId: '7', ownerName: 'Robert Anderson', microchipNumber: 'MC001234573', notes: 'Excellent sniffer' },
    { name: 'Mittens', species: 'Cat', breed: 'Tabby', dateOfBirth: new Date('2020-04-12'), ownerId: '8', ownerName: 'Lisa Taylor', microchipNumber: 'MC001234574', notes: 'Indoor cat only' },
    { name: 'Duke', species: 'Dog', breed: 'Bulldog', dateOfBirth: new Date('2017-07-08'), ownerId: '9', ownerName: 'William Thomas', microchipNumber: 'MC001234575', notes: 'Breathing issues monitored' },
    { name: 'Shadow', species: 'Cat', breed: 'Black Cat', dateOfBirth: new Date('2019-10-31'), ownerId: '10', ownerName: 'Amanda Garcia', microchipNumber: 'MC001234576', notes: 'Very playful' },
    { name: 'Daisy', species: 'Dog', breed: 'Poodle', dateOfBirth: new Date('2018-02-14'), ownerId: '1', ownerName: 'John Smith', microchipNumber: 'MC001234577', notes: 'Hypoallergenic' },
    { name: 'Oliver', species: 'Cat', breed: 'British Shorthair', dateOfBirth: new Date('2019-12-01'), ownerId: '2', ownerName: 'Sarah Johnson', microchipNumber: 'MC001234578', notes: 'Calm temperament' },
];

const appointmentData = [
    { patientId: null, patientName: 'Max', vetId: '1', vetName: 'Dr. Rebecca Foster', appointmentDate: new Date('2024-01-15T10:00:00'), appointmentType: 'Annual Checkup', status: 'Scheduled', reason: 'Routine examination' },
    { patientId: null, patientName: 'Luna', vetId: '1', vetName: 'Dr. Rebecca Foster', appointmentDate: new Date('2024-01-15T11:00:00'), appointmentType: 'Vaccination', status: 'Scheduled', reason: 'Rabies booster' },
    { patientId: null, patientName: 'Charlie', vetId: '2', vetName: 'Dr. James Chen', appointmentDate: new Date('2024-01-16T09:00:00'), appointmentType: 'Surgery Consultation', status: 'Scheduled', reason: 'Hip dysplasia' },
    { patientId: null, patientName: 'Bella', vetId: '5', vetName: 'Dr. Linda Kim', appointmentDate: new Date('2024-01-16T14:00:00'), appointmentType: 'Dermatology', status: 'Scheduled', reason: 'Skin irritation' },
    { patientId: null, patientName: 'Rocky', vetId: '4', vetName: 'Dr. Kevin Patel', appointmentDate: new Date('2024-01-17T10:30:00'), appointmentType: 'Cardiology', status: 'Scheduled', reason: 'Heart murmur checkup' },
];

async function seedDatabase() {
    try {
        await mongoose.connect(MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            useFindAndModify: false,
            useCreateIndex: true
        });

        console.log('Connected to MongoDB for seeding');

        // Clear existing data
        await mongoose.connection.db.dropDatabase();
        console.log('Database cleared');

        // Define schemas
        const patientSchema = new mongoose.Schema({
            name: String,
            species: String,
            breed: String,
            dateOfBirth: Date,
            ownerId: String,
            ownerName: String,
            microchipNumber: String,
            notes: String,
            createdAt: { type: Date, default: Date.now }
        });

        const appointmentSchema = new mongoose.Schema({
            patientId: String,
            patientName: String,
            vetId: String,
            vetName: String,
            appointmentDate: Date,
            appointmentType: String,
            status: String,
            reason: String,
            createdAt: { type: Date, default: Date.now }
        });

        const Patient = mongoose.model('Patient', patientSchema);
        const Appointment = mongoose.model('Appointment', appointmentSchema);

        // Insert patients
        const patients = await Patient.insertMany(patientData);
        console.log(`✓ Inserted ${patients.length} patients`);

        // Link appointments to patients
        for (let i = 0; i < appointmentData.length && i < patients.length; i++) {
            appointmentData[i].patientId = patients[i]._id.toString();
        }

        // Insert appointments
        const appointments = await Appointment.insertMany(appointmentData);
        console.log(`✓ Inserted ${appointments.length} appointments`);

        console.log('Database seeding completed successfully');
        await mongoose.connection.close();
    } catch (error) {
        console.error('Error seeding database:', error);
        process.exit(1);
    }
}

seedDatabase();
